function [beta,sigma] = horseshoeGibbs(draws,y,X,initBeta,a_prior,restrictions,prior,waitbar)
% Syntax:
%
% [beta,sigma] = nb_bVarEstimator.horseshoeGibbs(draws,y,X,initBeta,...
%                   a_prior,restrictions,prior,waitbar)
%
% Description:
%
% This function draws estimates of large BVAR equation-by-equation with a
% horseshoe prior on the VAR coefficients. This version implements a fast
% approximate scheme. However, the approximation disregards a term in the
% posterior probability of the draws. For more information on this issue,
% consult:
%
% Carriero, Chan, Clark, and Marcellino (2021), Corrigendum to "Large 
% Vector Autoregressions with stochastic volatility and non-conjugate 
% priors."
% 
% Input:
% 
% See nb_bVarEstimator.horseshoe
% 
% Output:
% 
% See nb_bVarEstimator.horseshoe
%
% Written by Maximilian Schröder

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    burn = prior.burn;
    thin = prior.thin;
    
    if nargin < 12
        waitbar = false;
        if nargin < 11
            burn = 10;
        end
    end

    % Waitbar
    [hh,note,isWaitbar] = nb_bVarEstimator.openWaitbar(waitbar,burn + draws);

    % model dimensions
    n = size(y,2); 
    K = size(X,2);
    p = (K-1)/n;
    
    % Preallocating
    T     = size(y,1);
    PAI   = initBeta;
    N     = size(a_prior,1);
    sigma = nan(n,n,draws);
    alpha = zeros(N,draws);
   
    % Horseshoe prior settings
    lambda  = prior.lambda*ones(n,K);
    tau     = prior.tau*ones(n,1);
    nu      = prior.nu*ones(n,K);
    xi      = prior.xi*ones(n,1);

    % Initial Conditions of Stochastic Volatility
    if prior.sv == 1
        Omega_t = 0.1*ones(T,n);
        sig     = 0.1*ones(n,1);
    end
    
    Omega             = 0.1*ones(1,n);
    OMEGA             = zeros(n,n,T);
    Omegac            = zeros(n*p,n*p,T);
    Omegac(1:n,1:n,:) = repmat(diag(Omega),1,1,T);
    QPhi              = 1*ones(K,n);
    A_                = eye(n);
    
    % choose gibbs sampler based on dimensions of problem
    algorithm = 1+double(K > T);
    
    %------------------------ Burnin Phase --------------------------------
    for ii = 1:burn
        
        % |--- Sample the Variances in Matrix Omega 
        
        resid = zeros(T,n);
        se    = (y - X*PAI).^2;
        if prior.sv == 0
            b1         = 0.01 + (T-p)/2; 
            b2         = 0.01 + sum(se)/2;             
            Omega(1,:) = 1./gamrnd(b1,1./b2);                
            Omega_t    = repmat(Omega,T,1);
        elseif prior.sv == 1

            error('Setting the prior options sv == 1 is not yet supported')

            % fystar  = log(se + 1e-6);
            % 
            % % stochastic volatility sampling using Chan's filter
            % for i = 1:r+ng
            %     [h(:,i), ~]  = SVRW(fystar(:,i),h(:,i),sig(i,:),4);                    
            %     Omega_t(:,i) = exp(h(:,i));                               
            %     r1           = 1 + (T-p-1)/2;   
            %     r2           = 0.01 + sum(diff(h(:,i)).^2)'/2;  
            %     sig(i,:)     = 1./gamrnd(r1./2,2./r2);
            % end
        end

        % |--- Sample the VAR Coefficients PAI and Covariances in Omega
        
        for i = 1:n                                 
            y_tilde = y(:,i)./sqrt(Omega_t(:,i));                 
            X_tilde = [X resid(:,1:i-1)]./sqrt(Omega_t(:,i));  
            
            % Sample coefficients from Normal Distribution
            VAR_coeffs  = randn_gibbs(y_tilde,X_tilde,[QPhi(:,i);9*ones(i-1,1)],T-p,K+i-1,algorithm);   
            PAI(:,i)    = VAR_coeffs(1:K);  
            A_(i,1:i-1) = VAR_coeffs(K+1:end);  
            
            % update the horseshoe prior parameters
            [QPhi(:,i),~,~,lambda(i,:),tau(i,1),nu(i,:),xi(i,1)] = ...
                horseshoe_prior(PAI(:,i)',K,tau(i,1),nu(i,:),xi(i,1));  
            
            % Update residual
            resid(:,i) = y(:,i) - [X resid(:,1:i-1)]*VAR_coeffs;
        end   
        
        % Ensure non-explosive draws
        PAIc    = [PAI(2:end,:)'; eye(n*(p-1)) zeros(n*(p-1),n)];       
        counter = 0;
        while max(abs(eig(PAIc)))>0.999

            counter = counter +1;
            if counter > 50
               warning('\n Trouble finding non-explosive draws! Consider terminating the estimation.')
            end
            
            for i = 1:n
                y_tilde = y(:,i)./sqrt(Omega_t(:,i));                 
                X_tilde = [X resid(:,1:i-1)]./sqrt(Omega_t(:,i));
                
                % Sample coefficients from Normal Distribution
                VAR_coeffs  = randn_gibbs(y_tilde,X_tilde,[QPhi(:,i);9*ones(i-1,1)],T-p,K+i-1,algorithm);   
                PAI(:,i)    = VAR_coeffs(1:K);  
                A_(i,1:i-1) = VAR_coeffs(K+1:end); 
                
                % update the horseshoe prior parameters
                [QPhi(:,i),~,~,lambda(i,:),tau(i,1),nu(i,:),xi(i,1)] = ...
                    horseshoe_prior(PAI(:,i)',K,tau(i,1),nu(i,:),xi(i,1)); 

                % Update residual
                resid(:,i) = y(:,i) - [X resid(:,1:i-1)]*VAR_coeffs;
            end
            PAIc = [PAI(2:end,:)'; eye(n*(p-1)) zeros(n*(p-1),n)];       
        end
        
        % construct the variance-covariance matrix
        OMEGA(:,:,1:p) = repmat(A_*diag(Omega_t(1,:))*A_',1,1,p);
        for t = 1:T-p    
            OMEGA(:,:,t+p) = A_*diag(Omega_t(t,:))*A_';
        end
        Omegac(1:n,1:n,:) = OMEGA;  

        if isWaitbar
            nb_bVarEstimator.notifyWaitbar(hh,ii,note);
        end
        
    end
    
    
    %--------------------- Post-Burnin Phase ------------------------------

    kk = 1;
    for ii = 1:draws*thin
        
        % |--- Sample the Variances in Matrix Omega 
        
        resid = zeros(T,n);
        se = (y - X*PAI).^2;
        if prior.sv == 0
            b1         = 0.01 + (T-p)/2; 
            b2         = 0.01 + sum(se)/2;             
            Omega(1,:) = 1./gamrnd(b1,1./b2);                
            Omega_t    = repmat(Omega,T,1);
        elseif prior.sv == 1

            error('Setting the prior options sv == 1 is not yet supported')

            % fystar  = log(se + 1e-6);
            % 
            % % stochastic volatility sampling using Chan's filter
            % for i = 1:r+ng
            %     [h(:,i), ~] = SVRW(fystar(:,i),h(:,i),sig(i,:),4);                    
            %     Omega_t(:,i)  = exp(h(:,i));                               
            %     r1 = 1 + (T-p-1)/2;   
            %     r2 = 0.01 + sum(diff(h(:,i)).^2)'/2;  
            %     sig(i,:) = 1./gamrnd(r1./2,2./r2);
            % end
        end

        % |--- Sample the VAR Coefficients PAI and Covariances in Omega
        
        for i = 1:n                                 
            y_tilde = y(:,i)./sqrt(Omega_t(:,i));                 
            X_tilde = [X resid(:,1:i-1)]./sqrt(Omega_t(:,i));  
            
            % Sample coefficients from Normal Distribution
            VAR_coeffs  = randn_gibbs(y_tilde,X_tilde,[QPhi(:,i);9*ones(i-1,1)],T-p,K+i-1,algorithm);   
            PAI(:,i)    = VAR_coeffs(1:K);  
            A_(i,1:i-1) = VAR_coeffs(K+1:end);  
            
            % update the horseshoe prior parameters
            [QPhi(:,i),~,~,lambda(i,:),tau(i,1),nu(i,:),xi(i,1)] = horseshoe_prior(PAI(:,i)',K,tau(i,1),nu(i,:),xi(i,1)); 

            % Update residual
            resid(:,i) = y(:,i) - [X resid(:,1:i-1)]*VAR_coeffs;
        end   
        
        % Ensure non-explosive draws
        PAIc    = [PAI(2:end,:)'; eye(n*(p-1)) zeros(n*(p-1),n)];       
        counter = 0;
        while max(abs(eig(PAIc))) > 0.999
           
            counter = counter + 1;
            if counter > 50
               warning('\n Trouble finding non-explosive draws! Consider terminating the estimation.')
            end
            
            for i = 1:n
                y_tilde = y(:,i)./sqrt(Omega_t(:,i));                 
                X_tilde = [X resid(:,1:i-1)]./sqrt(Omega_t(:,i));
                
                % Sample coefficients from Normal Distribution
                VAR_coeffs  = randn_gibbs(y_tilde,X_tilde,[QPhi(:,i);9*ones(i-1,1)],T-p,K+i-1,algorithm);   
                PAI(:,i)    = VAR_coeffs(1:K);  
                A_(i,1:i-1) = VAR_coeffs(K+1:end); 
                
                % update the horseshoe prior parameters
                [QPhi(:,i),~,~,lambda(i,:),tau(i,1),nu(i,:),xi(i,1)] = horseshoe_prior(PAI(:,i)',K,tau(i,1),nu(i,:),xi(i,1)); 

                % Update residual
                resid(:,i) = y(:,i) - [X resid(:,1:i-1)]*VAR_coeffs;
            end
            PAIc = [PAI(2:end,:)'; eye(n*(p-1)) zeros(n*(p-1),n)];       
        end
        
        % construct the variance-covariance matrix
        OMEGA(:,:,1:p) = repmat(A_*diag(Omega_t(1,:))*A_',1,1,p);
        for t = 1:T-p    
            OMEGA(:,:,t+p) = A_*diag(Omega_t(t,:))*A_';
        end
        Omegac(1:n,1:n,:) = OMEGA;   
    
        if rem(ii,thin) == 0
            alpha(:,kk)   = PAI(:);
            sigma(:,:,kk) = OMEGA(:,:,end); 
            kk            = kk + 1;
        end
        
        if isWaitbar
            nb_bVarEstimator.notifyWaitbar(hh,burn + kk,note);
        end
        
    end
    
    if isWaitbar
        nb_bVarEstimator.closeWaitbar(hh);
    end
    
    % Expand to include zero restrictions
    if ~isempty(restrictions)
        restrictions          = [restrictions{:}];
        alphaSub              = alpha;
        alpha                 = zeros(length(restrictions),draws);
        alpha(restrictions,:) = alphaSub;
    end
    
    % Reshape to matrix form
    beta = reshape(alpha,[K,n,draws]);
    
end

%==========================================================================
%----------------------- Auxiliary Functions ------------------------------
function [Q,invQ,miu,lambda,tau,nu,xi] = horseshoe_prior(beta,n,tau,nu,xi)
    
    % % -------------------------------------------------------------------
    % % This code is taken from: 
    % % Korobilis, D. and Shimizu, K. (2022). “Bayesian Approaches to Shrinkage and Sparse Estimation”
    % % in Foundations and Trends in Econometrics, 11, 230-354.
    % % -------------------------------------------------------------------
    
    % sample lambda and nu
    rate   = (beta.^2)/(2*tau) + 1./nu;
    lambda = min(1e+4,1./gamrnd(1,1./rate));    % random inv gamma with shape=1, rate=rate
    nu     = min(1e+3,1./gamrnd(1,1./(1 + 1./lambda)));    % random inv gamma with shape=1, rate=1+1/lambda_sq_12

    % sample tau and xi 
    rate = 1/xi + sum((beta.^2)./(2*lambda));
    tau  = min(1e+4,1/gamrnd((n+1)/2, 1/rate));    % inv gamma w/ shape=(p*(p-1)/2+1)/2, rate=rate
    xi   = min(1e+3,1/gamrnd(1,1/(1 + 1/tau)));    % inv gamma w/ shape=1, rate=1+1/tau_sq


    % update estimate of Q and Q^{-1}
    Q    = (lambda.*tau);
    invQ = 1./Q;

    % estimate of prior mean
    miu = zeros(length(beta),1);
    
end

%==========================================================================
function [Beta] = randn_gibbs(y,X,lambda,n,p,algorithm)

    % % -------------------------------------------------------------------
    % % This code is taken from: 
    % % Korobilis, D. and Shimizu, K. (2022). “Bayesian Approaches to Shrinkage and Sparse Estimation”
    % % in Foundations and Trends in Econometrics, 11, 230-354.
    % % -------------------------------------------------------------------
   
    if algorithm == 1
        % matrices %%
        Q_star = X'*X;
        Dinv   = diag(1./lambda);       
        L      = chol((Q_star + Dinv),'lower');
        v      = L\(y'*X)';
        mu     = L'\v;
        u      = L'\randn(p,1);
        Beta   = mu + u;
    elseif algorithm == 2
        U = bsxfun(@times,lambda,X');
        % step 1 %%
        u = normrnd(zeros(p,1),sqrt(lambda));
        %u = sqrt(lambda).*randn(p,1);  
        v = X*u + randn(size(X,1),1);
        % step 2 %%
        v_star = ((X*U) + eye(size(X,1)))\(y-v);
        Beta   = (u + U*v_star);
    end
end

%==========================================================================
% function [L, D] = ldl_golub(A)
%     n = length(A);
%     v = zeros(n,1);
%     for j = 1:n
%         for i = 1:j - 1
%             v(i) = A(j, i)*A(i, i);
%         end
%         A(j, j) = A(j, j) - A(j, 1:j - 1) * v(1:j - 1);
%         A(j + 1:n, j) = (A(j + 1:n,j) - A(j + 1:n, 1:j - 1) * v(1:j - 1))/A(j, j);
%     end
%     L = tril(A,-1)+eye(n);
%     D = diag(diag(A));
% end

%==========================================================================
% function [h, S] = SVRW(ystar,h,omega2h,Vh)
%     % % Univariate stochastic volatility
%     % %   with a random walk transition equation
%     % %
%     % % h_t    = h_{t-1} + v_t,    v_t ~ N(0,omega2h),
%     % % h_1 ~ N(0,Vh).
%     % %
%     % % See Chan, J.C.C. (2012) Moving average stochastic volatility models
%     % %     with application to inflation forecast
%     % % (c) 2012, Joshua Chan. Email: joshuacc.chan@gmail.com
%     % % =======================================================================
%     T = length(h);
%     % parameters for the Gaussian mixture
%     pi      = [0.0073 .10556 .00002 .04395 .34001 .24566 .2575];
%     mui     = [-10.12999 -3.97281 -8.56686 2.77786 .61942 1.79518 -1.08819] - 1.2704; 
%     sigma2i = [5.79596 2.61369 5.17950 .16735 .64009 .34023 1.26261];
%     sigmai  = sqrt(sigma2i);
% 
%     % sample S from a 7-point distrete distribution
%     temprand = rand(T,1);
%     q        = repmat(pi,T,1).*normpdf(repmat(ystar,1,7),repmat(h,1,7) +repmat(mui,T,1),repmat(sigmai,T,1));
%     q        = max(q,1e-20);
%     q        = q./repmat(sum(q,2),1,7);
%     S        = 7 - sum(repmat(temprand,1,7)<cumsum(q,2),2) + 1;
% 
%     % sample h
%     H         = speye(T) - sparse(2:T,1:(T-1),ones(1,T-1),T,T);
%     invOmegah = spdiags([1/Vh; 1/omega2h*ones(T-1,1)],0,T,T);
%     d         = mui(S)'; invSigystar = spdiags(1./sigma2i(S)',0,T,T);
%     Kh        = H'*invOmegah*H + invSigystar;
%     Ch        = chol(Kh,'lower');              % so that Ch*Ch' = Kh
%     hhat      = Kh\(invSigystar*(ystar-d));
%     h         = hhat + Ch'\randn(T,1);          % note the transpose
% end

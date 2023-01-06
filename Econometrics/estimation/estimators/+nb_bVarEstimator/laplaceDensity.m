function [beta,sigma] = laplaceDensity(y,x,initBeta,initSigma,lam2Prior,lam2,draws,burn,thin,waitbar)
% Syntax:
% [beta,sigma] = nb_bVarEstimator.laplaceDensity(y,x,initBeta,initSigma,
%   lam2Prior,lam2,draws,burn,thin,waitbar)
%
% Description:
%
% Draw from the posterior when using a laplace prior. 
% 
% Written by Atle Loneland

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % compute dimensions and form some useful matrices
    [T,numCoeff] = size(x);
    [~,numEq]    = size(y);
    if draws == 1
        burn = 0;
    end
    
    xx         = x'*x;
    sigma      = zeros(numEq,numEq,draws);
    store_beta = zeros(numCoeff,numEq,draws);
    
    %Number of total draws per equation
    numDraws           = draws + burn;    
    [h,note,isWaitbar] = nb_bVarEstimator.openWaitbar(waitbar,numDraws*numEq*thin);
    
    kk = 0;
    for n = 1:numEq
        
        xy = x'*y(:,n);
        
        % matrices to store output
        store_beta(:,n,1) = initBeta(:,n); 
        beta              = store_beta(:,n,1);
        sigma(n,n,1)      = initSigma(n,n); 
        s2                = sigma(n,n,1);
        
        % Gibbs sampler
        jj = 1;
        for i = 2:numDraws*thin
            
            % draw of w
            divZero = 1;
            while divZero >= 1
                invw    = invGaussRnd(.5./abs(lam2.*beta),.25*ones(numCoeff,1)/(s2*lam2^2));
                divZero = sum(isnan(invw));
            end

            % draw of beta
            invW    = diag(invw);
            betaMat = xx+invW;
            betahat = betaMat\xy;
  
            % Generate beta draws from Gaussian dist. p(betahat|w,s2,Y)         
            [betachol,flag] = chol(betaMat); 
            if flag > 0
                % Repair cholesky if betaMat is not positive definite.
                betachol = chol(betaMat+100*eps(norm(betaMat))*eye(numCoeff));
            end
            beta = betahat+sqrt(s2)*betachol\randn(numCoeff,1);
            
            % draw of s2
            res = y(:,n) - x*beta;
            SSE = res'*res;
            niu = SSE + sum((beta.^2).*invw) + .25*sum(1./invw)/(lam2^2);
            deg = T + 3*numCoeff - 2;
            s2  = 1./gamrnd(deg/2,2/niu);
            
            % draw of lam2, if it is not fixed
            if isempty(lam2Prior)
                v    = sum(1./invw)/(4*s2);
                deg  = 2*numCoeff - 1;
                lam2 = max(sqrt(1./gamrnd(deg/2,2/v)),1e-8); 
            end
            
            if rem(i,thin) == 0
                store_beta(:,n,jj) = beta;
                sigma(n,n,jj)      = s2;
                jj                 = jj + 1;
            end

            kk = kk + 1;
            % Update waitbar
            if isWaitbar
                nb_bVarEstimator.notifyWaitbar(h,kk,note);
            end
            
        end
        
    end
    
    if isWaitbar
        nb_bVarEstimator.closeWaitbar(h);
    end
    sigma = sigma(:,:,burn+1:numDraws);
    beta  = store_beta(:,:,burn+1:numDraws);
    
end

%==========================================================================
function r = invGaussRnd(mu,lambda)
    
    % Function that calculates Inverse-Gaussian. See the wikipedia section 
    % "Sampling_from_an_inverse-Gaussian_distribution" for more details: 
    % https://en.wikipedia.org/wiki/Inverse_Gaussian_distribution
    y = randn(length(mu),1).^2;
    x = mu + .5*(mu.^2).*y./lambda - .5*mu./lambda.*sqrt(4*mu.*lambda.*y + (mu.^2).*(y.^2));
    z = rand(length(mu),1);
    r = x.*(z<=(mu./(mu+x)))+(mu.^2)./x.*(z>(mu./(mu+x)));
end

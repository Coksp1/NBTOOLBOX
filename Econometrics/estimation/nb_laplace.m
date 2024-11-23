function [beta,sigma,lambda,residual,X] = nb_laplace(y,x,prior,constant,timeTrend,varargin)
% Syntax:
%
% beta                           = nb_laplace(y,x)
% [beta,sigma,lambda,residual,X] = nb_laplace(y,x,prior,constant,timeTrend)
%
% Description:
%
% Estimate multiple (assumed un-related) equations using Laplace-Diffuse 
% priors, i.e. bayesian LASSO.
%
% Uniform prior on constant:
%
% y(i) = I*betaC(i) + X*beta(i) + residual(i), residual(i) ~ N(0,sigma(i)) 
%
% Prior on betaC(i) : Diffuse prior
%
% Laplace prior on constant:
%
% y(i) = [I,X]*[betaC(i);beta(i)] + residual(i), residual(i) ~ N(0,sigma(i))
%
% Prior on betaC(i) : Laplace(0,2*sigma(i)^2/lambda)
%
% For both cases:
%
% Prior on beta(i)  : Laplace(0,2*sigma(i)^2/lambda)
% Prior on sigma(i) : Diffuse prior, which leads to a conditional 
%                     posterior that is InvGamma.
%
% If the prior on lambda is not set, we use a diffuse hyperprior, which
% leads to a conditional posterior that is InvGamma.
%
% This posterior mode of this estimator amount to LASSO. (But the mode is
% hard to calculate from the draws from the posterior!). And in this
% context we can interpret the lambda parameter as the shadow price of 
% the LASSO constraint, i.e. when forming the lagrangian of the LASSO 
% problem we have: 
%
% min (y - X*beta)^2 + lambda*(sum(abs(beta)) - 1/t)
%
% PS: Here we ignore the constant term!
%
% Input:
% 
% - y         : A double matrix of size T x Q of the dependent 
%               variable of the regression(s).
%
% - x         : A double matrix of size T x N of the right  
%               hand side variables of all equations of the 
%               regression.
%
% - prior     : A structure with the prior specification. If not given the 
%               default priors are the options returned by the 
%               nb_laplacePrior function.
%
%               If draws option is set to 1, the mode is returned. The mode
%               is estimated by using nb_lasso function.
%
% - constant  : If a constant is wanted in the estimation. Will be
%               added first in the right hand side variables. Default is 
%               false.
% 
% - timeTrend : If a linear time trend is wanted in the estimation. 
%               Will be added first/second in the right hand side 
%               variables. (First if constant is not given, else 
%               second). Default is false.
%
% Optional input:
%
% - 'initBeta'  : Initial values of beta, as a N x Q double, default is 
%                 to use the Ridge estimate with lagrange multiplier equal 
%                 to 8*(3/4)*lambda^4.
%
% - 'initSigma' : Initial values of sigma, as a Q x Q double, default is 
%                 to use the Ridge estimate with lagrange multiplier equal 
%                 to 8*(3/4)*lambda^4.
%
% - 'seed'      : Set the seed. Default is to not adjust the seed, i.e. 
%                 this input is set to []. If not empty, this input will 
%                 be given to the rng function.
%
% - 'waitbar'   : true or false.
%
% Output: 
% 
% - beta       : A (extra + N) x Q x draws matrix with the estimated 
%                parameters. Where extra is 0, 1 or 2 dependent
%                on the constant and/or time trend is included.
%
% - sigma      : A Q x Q x draws matrix with the covariance matrix of
%                residuals.
%
% - lambda     : A 1 x Q x draws matrix with the draws of lambda. If lambda
%                input
%
% - residual   : Residual from the estimated equation. As an T x Q matrix.
%                If draws > 1, this is calculated at the mean.
%
% - X          : Regressors including constant and time-trend. If more 
%                than one equation this will be given as kron(I,x).
% 
% See also
% nb_laplacePrior, nb_lasso
%
% Written by Atle Loneland and Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 5
        timeTrend = 0;
        if nargin < 4
            constant = 0;
        end
    end

    if prior.draws == 1
        if isempty(prior.lambda)
            error(['The lambda prior option cannot be empty if you want ',...
                'to return the mode (draws == 1).'])
        end
        [beta,exitflag,residual,X] = nb_lasso(y,x,prior.lambda,constant,[],...
            'mode','lagrangian','restrictConstant',prior.constantDiffuse);
        if exitflag < 0
            nb_interpretExitFlag(exitflag,'nb_laplace',[' Failed during ',...
                'mode estimation.'])
        end
        [T,Q] = size(y);
        sigma = zeros(Q,Q);
        for n = 1:Q
            sigma(n,n) = residual(:,n)'*residual(:,n)/(T - size(beta,1));
        end
        lambda = prior.lambda;
        if isscalar(lambda)
            lambda = ones(1,Q)*lambda;
        end
        return
    end

    % Parse optional inputs
    default = {
        'initBeta',  [],    {@(x)isnumeric(x),'||',@isempty};...
        'initSigma', [],    {@(x)isnumeric(x),'||',@isempty};...
        'seed',      [],    {@(x)nb_isScalarNumber(x),'||',@isempty};... 
        'waitbar',   false, @(x)or(nb_isScalarLogical(x),isa(x,'nb_waitbar5'));...
    };
    
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end 

    % Use the same seed when returning the "random" numbers
    if ~isempty(inputs.seed)
        rng(inputs.seed);
    end
    
    % NUmber of observations
    if isempty(x)
        T = size(y,1);
        x = zeros(T,0);
    else
        T = size(x,1);
    end
    
    % Add constant if wanted
    if timeTrend
        trend = 1:T;
        x     = [trend', x];
    end
    
    % Add constant if wanted
    if constant && ~prior.constantDiffuse       
        x = [ones(T,1), x];
    end
    if prior.constantDiffuse && constant
        xAll = [ones(T,1), x];
    else
        xAll = x;
    end

    N         = size(x,2) + double(prior.constantDiffuse && constant); 
    [nobs2,Q] = size(y);
    if (T ~= nobs2)
        error('x and y must have same # obs.'); 
    end
    if T < 3
        error('The estimation sample must be longer than 2 periods.');
    end
    if T <= N
        error(['The number of estimated parameters must be less than ',...
            'the number of observations.'])
    end

    % Prior options
    if isempty(prior.lambda)
        % Initial value for 1/lambda
        lam2 = sqrt(0.25/(8*N*0.75^2));
    else
        lam2 = 1./prior.lambda;
    end
    if isscalar(lam2)
        lam2 = lam2(1,ones(1,Q));
    elseif ~(isvector(lam2) && length(lam2) == Q)
        error(['The prior option lambda must have as many elements as the ',...
            'number of columns of the y input (dependent variable), i.e. ',...
            int2str(Q) '.'])
    end

    % Optional inputs
    initBeta  = inputs.initBeta;
    initSigma = inputs.initSigma;
    if isempty(initBeta)
        xInit = x;
        if prior.constantDiffuse && constant 
            xInit = [ones(T,1),x];
        end
        xx        = xInit'*xInit;
        initBeta  = zeros(N,Q);
        if isempty(initSigma)
            initSigma = zeros(Q,Q);
            doSigma   = true;
        else
            doSigma = false;
        end
        for n = 1:Q
            xy            = xInit'*y(:,n);
            ridgeLambda   = 6*max(lam2)^2;
            initBeta(:,n) = (xx + eye(N)/ridgeLambda)\xy;
            if doSigma
                res            = y(:,n) - xInit*initBeta(:,n);
                SSE            = res'*res;
                initSigma(n,n) = SSE/(T - N);
            end
        end
    end

    % compute dimensions and form some useful matrices
    xx           = x'*x;
    sigma        = zeros(Q,Q,prior.draws);
    store_beta   = zeros(N,Q,prior.draws);
    store_lambda = zeros(1,Q,prior.draws);
    
    %Number of total draws per equation
    numDraws           = prior.draws + prior.burn;    
    [h,note,isWaitbar] = nb_bVarEstimator.openWaitbar(inputs.waitbar,numDraws*Q*prior.thin);
    
    kk = 0;
    for n = 1:Q

        % Initial values
        beta = initBeta(:,n); 
        s2   = initSigma(n,n); 
        
        % Gibbs sampler
        jj = 1;
        for i = 2:numDraws*prior.thin
            
            yn = y(:,n);
            if prior.constantDiffuse && constant

                % Draw from the conditional posterior when using a diffuse 
                % prior, which is N(betaOLS,sigma*inv(X'*X)). In this case
                % we therfore end up with N(betaOLS,sigma/T)
                betaR   = beta(2:end);
                NR      = N - 1;
                yc      = yn - x*betaR;
                betaOLS = nb_ols(yc,ones(T,1));
                betaC   = betaOLS + sqrt(s2/T)*randn(1,1);

                % Substract the constant term from y, to get the
                % conditional posterior from here on correct
                yn = yn - ones(T,1)*betaC;

            else
                betaR = beta;
                NR    = N;
            end
            
            xy = x'*yn;

            % draw of w
            divZero = 1;
            while divZero >= 1
                check        = abs(betaR) < eps^(0.5);
                betaR(check) = eps^(0.5);
                invw         = invGaussRnd(.5./abs(lam2(n).*betaR),...
                    .25*ones(NR,1)/(s2*lam2(n)^2));
                divZero      = sum(isnan(invw));
            end

            % draw of beta
            invW    = diag(invw);
            betaMat = xx + invW;
            betahat = betaMat\xy;
  
            % Generate beta draws from Gaussian dist. p(betahat|w,s2,Y)         
            [betachol,flag] = chol(betaMat); 
            if flag > 0
                % Repair cholesky if betaMat is not positive definite.
                betachol = chol(betaMat + 100*eps(norm(betaMat))*eye(NR));
            end
            betaR = betahat + sqrt(s2)*betachol\randn(NR,1);
            if prior.constantDiffuse && constant
                beta = [betaC;betaR];
            else
                beta = betaR;
            end
            
            % Draw of s2, Posterior is given as InvGamma(deg,niu) or 
            % 1./Gamma(deg/2,niu/2) (caution the last input is inversed 
            % in the call to gamrnd!)
            res = y(:,n) - xAll*beta;
            SSE = res'*res;
            niu = SSE + sum((betaR.^2).*invw) + .25*sum(1./invw)/(lam2(n)^2);
            deg = T + 3*N - 2;
            s2  = 1./gamrnd(deg/2,2/niu);
            
            % Draw of lam2, if it is not fixed
            if isempty(prior.lambda)
                v       = sum(1./invw)/(4*s2);
                degLam  = 2*N - 1;
                lam2(n) = max(sqrt(1./gamrnd(degLam/2,2/v)),1e-8); 
            end
            
            if rem(i,prior.thin) == 0
                store_beta(:,n,jj)   = beta;
                sigma(n,n,jj)        = s2;
                store_lambda(:,n,jj) = 1/lam2(n);
                jj                   = jj + 1;
            end

            % Update waitbar
            kk = kk + 1;
            if isWaitbar
                nb_bVarEstimator.notifyWaitbar(h,kk,note);
            end
            
        end
        
    end
    
    if isWaitbar
        nb_bVarEstimator.closeWaitbar(h);
    end
    sigma  = sigma(:,:,prior.burn + 1:numDraws);
    beta   = store_beta(:,:,prior.burn + 1:numDraws);
    lambda = store_lambda(:,:,prior.burn + 1:numDraws);
    
    % Standard deviation of the estimated paramteres (beta)
    if nargout > 2
        residual = y - xAll*mean(beta,3);
        if nargout > 3
            X = kron(eye(Q),xAll);
        end
    end
    
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

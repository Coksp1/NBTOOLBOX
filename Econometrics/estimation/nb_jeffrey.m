function [beta,sigma,residual,X] = nb_jeffrey(y,x,prior,constant,timeTrend,restrictions)
% Syntax:
%
% beta                    = nb_jeffrey(y,x)
% [beta,sigma,residual,X] = nb_jeffrey(y,x,prior,constant,timeTrend,...
%   restrictions)
%
% Description:
%
% Estimate multiple (related) equations using Jeffrey priors.
%
% y = X*beta + residual, residual ~ N(0,sigma) (1)
%
% Prior on beta  : Diffuse
% Prior on sigma : Diffuse
%
% Input:
% 
% - y            : A double matrix of size T x Q of the dependent 
%                  variable of the regression(s).
%
% - x            : A double matrix of size T x N of the right  
%                  hand side variables of all equations of the 
%                  regression.
%
% - prior        : A structure with the prior specification. If not given  
%                  the default priors are:
%                  > draws   : 1
%
%                  For more on this prior see nb_jeffreyPrior.
%
% - constant     : If a constant is wanted in the estimation. Will be
%                  added first in the right hand side variables. Default  
%                  is false.
% 
% - timeTrend    : If a linear time trend is wanted in the estimation. 
%                  Will be added first/second in the right hand side 
%                  variables. (First if constant is not given, else 
%                  second). Default is false.
%
% - restrictions :
% Output: 
% 
% - beta       : A (extra + nxvar) x nEq x draws matrix with the estimated 
%                parameters. Where extra is 0, 1 or 2 dependent
%                on the constant and/or time trend is included.
%
% - sigma      : A nEq x nEq x draws matrix with the covariance matrix of
%                residuals.
%
% - residual   : Residual from the estimated equation. As an 
%                nobs x nEq matrix. If draws > 1, this is calculated at the
%                mean.
%
% - X          : Regressors including constant and time-trend. If more 
%                than one equation this will be given as kron(I,x).
% 
% See also
% nb_jeffreyPrior, nb_bayesEstimator, nb_singleEq
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 6
        restrictions = {};
        if nargin < 5
            timeTrend = 0;
            if nargin < 4
                constant = 0;
                if nargin < 3
                    prior = struct();
                end
            end
        end
    end
    
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
    if constant        
        x = [ones(sizeX,1), x];
    end

    N         = size(x,2); 
    [nobs2,Q] = size(y);
    if (T ~= nobs2)
        error([mfilename ':: x and y must have same # obs.']); 
    end
    if T < 3
        error([mfilename ':: The estimation sample must be longer than 2 periods.']);
    end
    if T <= N
        error([mfilename ':: The number of estimated parameters must be less than the number of observations.'])
    end
    
    if isfield(prior,'draws')
        draws = prior.draws;
        if isempty(draws)
            draws = 1;
        elseif ~nb_isScalarInteger(draws,0)
            error('The draws input must be a scalar positive integer.')
        end
    else
        draws = 1;
    end
    
    if isempty(restrictions)
        [A_OLS,~,~,~,res,X] = nb_ols(y,x,constant,timeTrend);
    else
        [A_OLS,~,~,~,res,X] = nb_olsRestricted(y,x,restrictions,constant,timeTrend);
    end
    a_ols          = A_OLS(:);
    T              = size(res,1);
    SSE            = res'*res;
    S_post         = SSE/(T - N); % Should these be adjusted differently for restricted equations?
    
    % Draw from the posterior?
    if draws > 1
        [beta,sigma] = jeffreyMCI(draws,X,T,N,Q,S_post,SSE,a_ols,restrictions,waitbar);
    else
        beta  = reshape(a_ols,[N,Q]);
        sigma = S_post;
    end
    
    % Standard deviation of the estimated paramteres (beta)
    if nargout > 4
        residual = y - x*mean(beta,3);
    end
    
end

%==========================================================================
function [beta,sigma] = jeffreyMCI(draws,X,T,numCoeff,nEq,initSigma,SSE,a_ols,restrictions,waitbar)
% Monte carlo integration of the model with Jeffrey prior.

    % Draw from posterior
    sigmaD  = initSigma;
    nUnrest = size(a_ols,1);
    alpha   = nan(nUnrest,draws);
    sigma   = nan(nEq,nEq,draws);
    if isempty(restrictions)
        X    = X(1:T,1:numCoeff);
        Xinv = inv(X'*X);
    end
    
    % Waitbar
    if or(nUnrest > 250,~isempty(restrictions) && nUnrest > 25)
        [h,note,isWaitbar] = openWaitbar(waitbar,draws);
    else
        isWaitbar = false;
    end
   
    for ii = 1:draws
    
        % Posterior of alpha|SIGMA,Data ~ Normal
        if ~isempty(restrictions)
            VARIANCE = kron(inv(sigmaD),eye(T));
            V_post   = (X'*VARIANCE*X)\eye(nUnrest);
        else
            V_post = kron(sigmaD,Xinv);
        end
        alpha(:,ii) = a_ols + chol(V_post)'*randn(nUnrest,1);% Draw alpha

        % Posterior of SIGMA|Data ~ iW(SSE,T-K) 
        sigmaD        = nb_distribution.invwish_rand(SSE,T-numCoeff);% Draw SIGMA 
        sigma(:,:,ii) = sigmaD;
        
        % Update waitbar
        if isWaitbar
            nb_bVarEstimator.notifyWaitbar(h,ii,note);
        end
        
    end
    
    if isWaitbar
        nb_bVarEstimator.closeWaitbar(h);
    end
    
    % Expand to include zero restrictions
    if ~isempty(restrictions)
        restrictions          = [restrictions{:}];
        alphaSub              = alpha;
        alpha                 = zeros(length(restrictions),draws);
        alpha(restrictions,:) = alphaSub;
    end
     
    if isWaitbar
        nb_bVarEstimator.closeWaitbar(h);
    end
    
    % Reshape to matrix form
    beta = reshape(alpha,[numCoeff,nEq,draws]); 
    
end

%==========================================================================
function [h,note,isWaitbar] = openWaitbar(waitbar,iter)
% Open up waitbar for producing posterior draws.

    isWaitbar = true;
    note      = nb_when2Notify(iter);
    if isa(waitbar,'nb_waitbar5')
        h                = waitbar;
        h.maxIterations4 = iter;
        h.text4          = 'Working...';
    elseif ismember(waitbar,[0,1])
        if waitbar
            h                = nb_waitbar5([],'Posterior draws',false,false);
            h.maxIterations4 = iter;
            h.text4          = 'Working...';
        else
            h         = [];
            isWaitbar = false;
        end
    else
        error([mfilename ':: Wrong input given to the waitbar option.']) 
    end
    
end

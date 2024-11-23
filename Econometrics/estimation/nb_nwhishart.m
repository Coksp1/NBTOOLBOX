function [beta,sigma,residual,X] = nb_nwhishart(y,x,prior,constant,timeTrend)
% Syntax:
%
% beta                    = nb_nwhishart(y,x)
% [beta,sigma,residual,X] = nb_nwhishart(y,x,prior,constant,timeTrend)
%
% Description:
%
% Estimate multiple (related) equations using Normal-Wishart priors.
%
% y = X*beta + residual, residual ~ N(0,sigma) (1)
%
% Prior on beta  : N(A_prior,V_prior)
% Prior on sigma : IW(S_prior,v_prior)
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
%               default priors are:
%               > A_prior : 0
%               > V_prior : Identity matrix times 10.
%               > S_prior : 0
%               > v_prior : N + 1
%               > draws   : 1
%
%               For more on this prior see nb_nwhishartPrior.
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
% nb_nwhishartPrior, nb_bayesEstimator, nb_singleEq
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 5
        timeTrend = 0;
        if nargin < 4
            constant = 0;
            if nargin < 3
                prior = struct();
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
    
    % Prior on vec(beta) ~ N(vec(A_prior), Sigma x diag(v_prior))
    if isfield(prior,'A_prior')
        A_prior = prior.A_prior;
        if isempty(A_prior)
            A_prior = zeros(N,Q);
        elseif nb_isScalarNumber(A_prior)
            A_prior = ones(N,Q)*A_prior;
        else
            if ~nb_sizeEqual(A_prior,[N,Q])
                error(['The A_prior does not have size ' int2str(N) ' x ' int2str(Q)])
            end
        end
    else
        A_prior = zeros(N,Q); 
    end
    
    if isfield(prior,'V_prior')
        V_prior = prior.V_prior;
        if isempty(V_prior)
            V_prior = diag(10*ones(N*Q,1));
        elseif nb_isScalarNumber(V_prior)
            V_prior = diag(V_prior*ones(N*Q,1));
        elseif isvector(V_prior)
            if ~numel(V_prior) ~= N*Q
                error(['If V_prior is a vector it must have size ' int2str(N*Q) ' x 1'])
            end
        else
            if ~nb_sizeEqual(V_prior,[N*Q,N*Q])
                error(['If V_prior is a matrix it have size ' int2str(N*Q) ' x ' int2str(N*Q)])
            end
        end
    else
        V_prior = diag(10*ones(N*Q)); 
    end
    
    % Prior on Sigma ~ IW(S_prior,v_prior)
    if isfield(prior,'S_prior')
        S_prior = prior.S_prior;
        if isempty(S_prior)
            S_prior = diag(zeros(1,Q));
        else
            if ~nb_sizeEqual(S_prior,[Q,Q])
                error(['The A_prior does not have size ' int2str(N) ' x ' int2str(Q)])
            end
        end
    else
        S_prior = diag(zeros(1,Q)); 
    end
    
    if isfield(prior,'v_prior')
        v_prior = prior.v_prior;
        if isempty(v_prior)
            v_prior = N + 1;
        else
            if ~isscalar(v_prior)
                error(['The v_prior must be a scalar.'])
            end
        end
    else
        v_prior = N + 1;
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
    
    % OLS estimate 
    [A_OLS,~,~,~,r,X] = nb_ols(y,x);
    SSE               = r'*r;   

    % Posterior vec(beta) | sigma, Y ~ N(a_post,kron(sigma,V_post))
    xx          = x'*x;
    V_prior_inv = V_prior\eye(N*Q);
    A_post      = (xx + V_prior_inv)\(x'*y + V_prior_inv*A_prior);
    a_post      = A_post(:);
    V_post      = (xx + V_prior_inv)\eye(N);
    
    % Posterior Sigma | Y ~ IW(S_post,v_post)
    S_post      = SSE + S_prior + A_OLS'*xx*A_OLS + A_prior'*V_prior_inv*A_prior - A_post'*(V_prior_inv + xx)*A_post;
    v_post      = v_prior + T;
    
    % Draw from the posterior?
    if draws > 1
        [beta,sigma] = nwishartMCI(draws,A_OLS,S_post,a_post,V_post,S_post,v_post,waitbar);
    else
        beta  = A_post;
        sigma = S_post/v_post;
    end
    
    % Standard deviation of the estimated paramteres (beta)
    if nargout > 2
        residual = y - x*mean(beta,3);
    end
    
end

%==========================================================================
function [beta,sigma] = nwishartMCI(draws,initBeta,initSigma,a_post,V_post,S_post,v_post,waitbar)
% Monte carlo integration of the model with Normal-Wishart prior.

    % Waitbar
    [h,note,isWaitbar] = openWaitbar(waitbar,draws);

    % Draw from posterior
    sigmaD         = initSigma;
    [numCoeff,nEq] = size(initBeta);
    N              = size(a_post,1);
    alpha          = nan(N,draws);
    sigma          = nan(nEq,nEq,draws);
    for ii = 1:draws
    
        % This is the covariance for the posterior density of alpha
        sigmaBig      = kron(sigmaD,V_post);
        [vv,dd]       = eig(sigmaBig);
        chol_sigmaBig = real(vv*sqrt(dd));
    
        % Posterior of alpha|SIGMA,Data ~ Normal
        alpha(:,ii) = a_post + chol_sigmaBig*randn(N,1);  % Draw alpha
        
        % Posterior of SIGMA|ALPHA,Data ~ iW(S_post,v_post)
        sigmaD        = nb_distribution.invwish_rand(S_post,v_post);% Draw SIGMA
        sigma(:,:,ii) = sigmaD;
        
        % Update waitbar
        if isWaitbar
            nb_bVarEstimator.notifyWaitbar(h,ii,note);
        end
        
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

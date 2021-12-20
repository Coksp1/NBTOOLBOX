function [beta,sigma,X,posterior,pY] = glp(draws,y,x,nLags,constant,constantAR,timeTrend,prior,restrictions,waitbar)
% Syntax:
%
% beta = nb_bVarEstimator.glp(draws,y,x,nLags,...
%    constant,constantAR,timeTrend,prior,restrictions,waitbar)
%
% [beta,sigma,X,posterior,pY] = nb_bVarEstimator.glp(draws,y,x,nLags,...
%    constant,constantAR,timeTrend,prior,restrictions,waitbar)
%
% Description:
%
% Estimate VAR model using prior used in the paper by Giannone, Lenza and
% Primiceri (2014), "Prior selection for vector autoregressions" and 
% Giannone, Lenza and Primiceri (2017), "Priors for the long run".
%
% Input:
% 
% - y            : A double matrix of size nobs x neq of the dependent 
%                  variable of the regression(s).
%
% - x            : A double matrix of size nobs x h + neq*nlags. Where h
%                  is the exogenous variables of the model.
%
% - nLags        : Number of lags of the VAR. As an integer
%
% - constant     : If a constant is wanted in the estimation. Will be
%                  added first in the right hand side variables.
% 
% - constantAR   : Include constant in AR models that is used to set up 
%                  the prior for sigma.
%
% - timeTrend    : If a linear time trend is wanted in the estimation. 
%                  Will be added first/second in the right hand side 
%                  variables. (First if constant is not given, else 
%                  second) 
%
% - prior        : A struct with the prior options. See
%                  nb_var.priorTemplate for more on this input
%
% - restrictions : Index of parameters that are restricted to zero.
%
% - waitbar      : true, false or an object of class nb_waitbar5.
%
% Output: 
% 
% - beta       : A (extra + neq*nlags + h) x neq x draws matrix with the  
%                posterior draws of the estimted coefficents.
%
%                Caution : If nargout == 1, this output is the marginal
%                          likelihood.
%
% - sigma      : A neq x neq x draws matrix with the posterior variance of 
%                the the estimated coefficients. 
%
% - X          : Regressors including constant and time-trend.
% 
% - posterior  : A struct with all the needed information to do posterior
%                draws.
%
% - pY         : Log marginal likelihood.
%
% See also
% nb_bVarEstimator.estimate, nb_var, nb_bVarEstimator.logMarginalLikelihood
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 10
        waitbar = 0;
        if nargin < 9
            restrictions = {};
            if nargin < 8
                prior = nb_bVarEstimator.priorTemplate('glp');
                if nargin < 7
                    timeTrend = 0;
                    if nargin < 6
                        constantAR = 0;
                        if nargin < 5
                            constant = 0;
                        end
                    end
                end
            end
        end
    end

    if ~isempty(restrictions)
        error([mfilename ':: Block exogenous variables cannot be declared with the Giannone, Lenza and Primiceri (2014) prior.'])
    end
    
    S_scale = 1;
    if isfield(prior,'S_scale')
        S_scale = prior.S_scale;
    end
    
    % Are we dealing with all zero regressors?
    [Traw,numDep] = size(y);
    [x,indZR]     = nb_bVarEstimator.removeZR(x,constant,timeTrend,numDep,0);
    
    % Initialize priors
    %-----------------------
    if timeTrend
        trend = 1:Traw;
        x     = [trend', x];
    end
    if constant        
        x = [ones(Traw,1), x];
    end
    numCoeff = size(x,2);
    nExo     = numCoeff - nLags*numDep;
    
    % Get the prior options
    lambda  = prior.lambda;
    Vc      = prior.Vc;
    ARcoeff = prior.ARcoeff;
    
    % Prior mean on VAR regression coefficients
    %------------------------------------------
    A_prior = [zeros(nExo,numDep); ARcoeff*eye(numDep); zeros((nLags-1)*numDep,numDep)];   
    a_prior = A_prior(:);
    if isfield(prior,'coeffInt')
        % Specific priors, see nb_estimator.getSpecificPriors
        p               = prior.coeffInt;
        a_prior(p(:,1)) = p(:,2);
    end
    A_prior = reshape(a_prior,[numCoeff,numDep]);
    
    % Minnesota Variance on VAR regression coefficients
    %--------------------------------------------------
    TrawAR = Traw;
    if isfield(prior,'LR')
        % We don't want the dummy observation of the long run prior mess
        % up the minnesota prior itself, so here we remove the dummy
        % observation temporarily
        if prior.LR || prior.SC 
            yT     = y(1:end-numDep,:);
            TrawAR = TrawAR - numDep;
        elseif prior.DIO
            yT     = y(1:end-1,:);
            TrawAR = TrawAR - 1;
        else
            yT = y;
        end
    else
        yT = y;
    end
    
    % Now get residual variances of univariate autoregressions. 
    % Here we just run the AR(1) model on each equation, ignoring the 
    % constant and exogenous variables (if they have been specified for  
    % the original VAR model).
    normFac  = 2 + constantAR + timeTrend; 
    s_prior  = zeros(1,numDep);
    for ii = 1:numDep
        
        % Create lags of dependent variables   
        yLag_i = nb_mlag(yT(:,ii),1);
        yLag_i = yLag_i(2:TrawAR,:);
        y_i    = yT(2:TrawAR,ii);
        
        % OLS estimates of i-th equation
        [~,~,~,~,res] = nb_ols(y_i,yLag_i,constantAR,timeTrend);
        s_prior(ii)   = (1./(TrawAR-normFac))*(res'*res);
        
    end
    
    % Setting up the priors (See appendix B of GLP (2017))
    %----------------------------------------------------------------------
    v_prior         = zeros(numCoeff,1);
    v_prior(1:nExo) = Vc;
    numDep2         = numDep + 2;
    for ii = 1:nLags
        ind          = nExo + (ii - 1)*numDep + 1:nExo + ii*numDep;
        v_prior(ind) = (numDep2 - numDep - 1)*(lambda^2)*(1/(ii^2))./s_prior;
    end
    V_prior_inv = diag(1./v_prior);
    
    % Prior scale matrix for the covariance of the shocks. See Kadiyala 
    % and Karlsson (1997)
    priorSigma = diag(s_prior);
    
    % Posteriors (here we assume a normal-wishart type prior)
    xx     = x'*x;
    A_post = (xx + V_prior_inv)\(x'*y + V_prior_inv*A_prior);
    eps    = y - x*A_post;
    
    % sigma | Y ~ IW(S_post,v_post)
    v_post = Traw - nLags + numDep + 2;
    S_post = S_scale*priorSigma + eps'*eps  + (A_post - A_prior)'*V_prior_inv*(A_post - A_prior);
    
    % vec(beta) | sigma, Y ~ N(a_post,kron(sigma,V_post))
    I      = eye(size(V_prior_inv,1));
    a_post = A_post(:);
    V_post = (xx + V_prior_inv)\I;
    
    if nargout == 1
        % In this case we report the marginal likelihood p(Y)
        beta = logMarginalLikelihood(prior,Traw,numDep,y,x,v_post - Traw + nLags,A_prior,s_prior,v_prior,V_prior_inv,S_post);
    else
    
        % Simulate from posterior using Monte carlo integration
        if draws > 1
            [beta,sigma] = nb_bVarEstimator.nwishartMCI(draws,A_post,S_post,a_post,V_post,S_post,v_post,restrictions,waitbar);
        else
            beta  = reshape(a_post,[numCoeff,numDep]);
            sigma = S_post/v_post;
        end

        % Return all needed information to do posterior draws
        if nargout > 2
            X = kron(eye(numDep),x);
            if nargout > 3
                posterior = struct('type','glp','betaD',beta,'sigmaD',sigma,'dependent',y,...
                                   'a_post',a_post,'S_post',S_post,'v_post',v_post,...
                                   'V_post',V_post,'restrictions',{restrictions});
                if nargout > 4
                    pY = logMarginalLikelihood(prior,Traw,numDep,y,x,v_post - Traw + nLags,A_prior,s_prior,v_prior,V_prior_inv,S_post);
                end
            end
        end
        
    end
    
    % Expand to include all zero regressors
    if any(~indZR)
        beta = nb_bVarEstimator.expandZR(beta,indZR); 
    end
    
end

%==========================================================================
function pY = logMarginalLikelihood(prior,Traw,numDep,y,x,d,A_prior,s_prior,v_prior,V_prior_inv,S_post)

    xx = x'*x;
    pY = nb_bVarEstimator.logMarginalLikelihood(Traw,numDep,d,xx,s_prior,v_prior,V_prior_inv,S_post);
    if prior.LR || prior.SC || prior.DIO
        if prior.LR || prior.SC
            yd = y(end-numDep+1:end,:);
            xd = x(end-numDep+1:end,:);
        else
            yd = y(end,:);
            xd = x(end,:);
        end
        norm = nb_bVarEstimator.dummyNormalizationConstant(yd,xd,d,A_prior,s_prior,v_prior,V_prior_inv);
        pY   = pY - norm;
    end
        
end

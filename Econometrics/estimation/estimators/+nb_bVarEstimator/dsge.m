function [beta,sigma,X,posterior,pY] = dsge(draws,y,x,nLags,constant,timeTrend,prior,restrictions,waitbar)
% Syntax:
%
% beta = nb_bVarEstimator.dsge(draws,y,x,nLags,...
%    constant,timeTrend,prior,restrictions,waitbar)
%
% [beta,sigma,X,posterior,pY] = nb_bVarEstimator.dsge(draws,y,x,nLags,...
%    constant,timeTrend,prior,restrictions,waitbar)
%
% Description:
%
% Estimate VAR model using dsge-prior, as in Del Negro and Schorfheide 
% (2004), "Priors from General Equilibrium Models for VARS".
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 9
        waitbar = 0;
        if nargin < 8
            restrictions = {};
            if nargin < 7
                prior = nb_bVarEstimator.priorTemplate('glp');
                if nargin < 6
                    timeTrend = 0;
                    if nargin < 5
                        constant = 0;
                    end
                end
            end
        end
    end

    if prior.LR || prior.SC || prior.DIO || prior.SVD
        error('Cannot apply dummy priors for the DSGE prior')
    end
    if ~isempty(restrictions)
        error([mfilename ':: Block exogenous variables cannot be declared with the Giannone, Lenza and Primiceri (2014) prior.'])
    end
    
    % Are we dealing with all zero regressors?
    [T,numDep] = size(y);
    [x,indZR]  = nb_bVarEstimator.removeZR(x,constant,timeTrend,numDep,0);
    
    % Initialize priors
    %-----------------------
    if timeTrend
        error('The option time_trend is not supported for the prior DSGE!')
    end
    if constant        
        x = [ones(T,1), x];
    end
    numCoeff = size(x,2);
    nExo     = numCoeff - nLags*numDep;
    if nExo > constant
        error('Cannot add any other exogenous variables than the constant for the dsge prior.')
    end
    
    % Priors
    %----------------------------------------------------------------------
    
    prior.GammaYX = transpose(prior.GammaXY);
    
    % vec(beta) | sigma, Y ~ N(vec(A_prior),kron(sigma,V_prior))
    A_prior     = prior.GammaXX\prior.GammaXY;
    I           = eye(size(A_prior,1));
    V_prior_inv = prior.lambda*T*prior.GammaXX;
    
    % sigma | Y ~ IW(lambda*T*S_prior,v_prior)
    S_prior = prior.lambda*T*(prior.GammaYY - prior.GammaYX*A_prior);
    %v_prior = T - numCoeff;
    
    % Setting up for posterior draws
    %----------------------------------------------------------------------
    
    % Posteriors (here we assume a normal-wishart type prior)
    xx     = x'*x;
    A_post = (prior.lambda*T*prior.GammaXX + xx)\(prior.lambda*T*prior.GammaXY + x'*y);

    % sigma | Y ~ IW(S_post,v_post)
    v_post = (1 + prior.lambda)*T - numCoeff;
    S_post = (prior.lambda*T*prior.GammaYY + y'*y - (prior.lambda*T*prior.GammaYX + y'*x)*A_post)./((prior.lambda + 1)*T);
    
    % vec(beta) | sigma, Y ~ N(a_post,kron(sigma,V_post))
    a_post = A_post(:);
    V_post = (V_prior_inv + xx)\I;
    
    if nargout == 1
        % In this case we report the marginal likelihood p(Y)
        if prior.lambda < (numCoeff + numDep)/T
            beta = inf;
        else
            beta = logMarginalLikelihood(prior,T,numDep,numCoeff,x,S_prior,S_post,V_prior_inv);
        end
    else
    
        if prior.lambda < (numCoeff + numDep)/T
            error(['Improper value of lambda, must at least be; ' num2str((numCoeff + numDep)/T)])
        end
        
        % Simulate from posterior using Monte carlo integration
        if draws > 1
            [beta,sigma] = nb_bVarEstimator.nwishartMCI(draws,A_post,S_post,a_post,V_post,S_post,v_post,restrictions,waitbar);
        else
            beta  = A_post;
            sigma = S_post/v_post;
        end

        % Return all needed information to do posterior draws
        if nargout > 2
            X = kron(eye(numDep),x);
            if nargout > 3
                posterior = struct('type','dsge','betaD',beta,'sigmaD',sigma,'dependent',y,...
                                   'a_post',a_post,'S_post',S_post,'v_post',v_post,...
                                   'V_post',V_post,'restrictions',{restrictions});
                if nargout > 4
                    pY = logMarginalLikelihood(prior,T,numDep,numCoeff,x,S_prior,S_post,V_prior_inv);
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
function pY = logMarginalLikelihood(prior,T,n,k,x,S_prior,S_post,V_prior_inv)

    % Calculate the marginal likelihood p(Y)
    Ta = (prior.lambda + 1)*T;
    Td = prior.lambda*T;
    pY = - 0.5*n*T*log(2*pi) + 0.5*n*(Ta - k)*log(2) - 0.5*n*(Td - k)*log(2)...
         + sum(gammaln(0.5*(Ta - k - (0:n-1))) - gammaln(0.5*(Td - k - (0:n-1)))) ...
         + 0.5*n*log(det(Td*prior.GammaXX)) ...
         + 0.5*(Td - k)*log(det(S_prior)) ...
         - 0.5*(Ta - k)*log(det(Ta*S_post)) ...
         - 0.5*n*log(det(x'*x + V_prior_inv));
      
end

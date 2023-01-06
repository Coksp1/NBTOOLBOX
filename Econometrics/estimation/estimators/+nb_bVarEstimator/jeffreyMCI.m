function [beta,sigma] = jeffreyMCI(draws,X,T,numCoeff,nEq,initSigma,SSE,a_ols,restrictions,waitbar)
% Syntax:
%
% [beta,sigma] = nb_bVarEstimator.jeffreyMCI(draws,X,T,numCoeff,nEq,...
%                       initSigma,SSE,a_ols,restrictions,waitbar)
%
% Description:
%
% Monte carlo integration of B-VAR with diffuse (Jeffery) prior.
% 
% This code is based on the paper by Koop and Korobilis (2009), 
% Bayesian Multivariate Time Series Methods for Empirical Macroeconomics.
%
% See also the DAG.pdf documentation.
%
% Input:
% 
% See nb_bVarEstimator.jeffrey
% 
% Output:
% 
% See nb_bVarEstimator.jeffrey
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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
        [h,note,isWaitbar] = nb_bVarEstimator.openWaitbar(waitbar,draws);
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
    
    % Reshape to matrix form
    beta = reshape(alpha,[numCoeff,nEq,draws]); 
    
end

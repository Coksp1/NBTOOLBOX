function [beta,sigma] = nwishartMCI(draws,initBeta,initSigma,a_post,V_post,S_post,v_post,~,waitbar)
% Syntax:
%
% [beta,sigma] = nb_bVarEstimator.nwishartMCI(draws,initBeta,initSigma,...
%                       a_post,V_post,S_post,v_post,restrictions,waitbar)
%
% Description:
%
% Monte carlo integration of B-VAR with Normal-Wishart prior.
%
% This code is based on code from a paper by Koop and Korobilis (2009), 
% Bayesian Multivariate Time Series Methods for Empirical Macroeconomics.
%
% See page 9 of Koop and Korobilis (2009)
%
% Input:
% 
% See nb_bVarEstimator.nwishart
% 
% Output:
% 
% See nb_bVarEstimator.nwishart
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Waitbar
    [h,note,isWaitbar] = nb_bVarEstimator.openWaitbar(waitbar,draws);

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

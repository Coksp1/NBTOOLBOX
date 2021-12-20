function pY = logMarginalLikelihood(T,n,d,xx,PSI,Omega,OmageInv,SigmaPost)
% Syntax:
%
% pY = nb_bVarEstimator.logMarginalLikelihood(T,n,d,xx,PSI,Omega,...
%               OmageInv,SigmaPost)
%
% Description:
%
% Calculate the marginal likelihood of a B-VAR model with a normal-whishart
% prior. See Appendix A of Giannone, Lenza and Primiceri (2014), "Prior  
% selection for vector autoregressions".
%
% Input:
%
% - T         : Number of observation.
%
% - n         : Number of dependent variables of the VAR.
%
% - d         : Number of degrees of freedom of the prior on Sigma.
%
% - xx        : Calculated as x'x, where x is the regressors of the VAR.
%
% - PSI       : Prior of Sigma.
%
% - Omega     : Scale matrix of the prior of beta.
%
% - OmegaInv  : Invers of the scale matrix of the prior of beta.
%
% - SigmaPost : Posterior of Sigma.
%
% Output:
%
% - pY : Log marginal likelihood.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Log determinant of prior on Sigma
    if isvector(PSI)
        ldPSI = sum(log(PSI));
    else
        ldPSI = sum(det(PSI));
    end

    % Log determinant of scale matrix of the prior of beta.
    if isvector(Omega)
        ldOmega = sum(log(Omega));
    else
        ldOmega = log(det(Omega));
    end
    
    % Log determinant of x'*x + OmageInv
    ldXXOmageInv = log(det(xx + OmageInv));

    % Log determinant of posterior of Sigma
    ldSigmaPost = log(det(SigmaPost));

    % Calculate the marginal likelihood p(Y)
    % T is here actually T-p!
    pY = - 0.5*n*T*log(pi) ...
         + sum(gammaln(0.5*(T + d - (0:n-1))) - gammaln(0.5*(d - (0:n-1)))) ...
         - 0.5*n*ldOmega + 0.5*d*ldPSI ...
         - 0.5*n*ldXXOmageInv ...
         - 0.5*(T + d)*ldSigmaPost;
       
end

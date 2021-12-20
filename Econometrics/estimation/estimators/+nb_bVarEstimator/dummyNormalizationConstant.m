function norm = dummyNormalizationConstant(yd,xd,d,priorBeta,PSI,Omega,OmageInv)
% Syntax:
%
% norm = nb_bVarEstimator.dummyNormalizationConstant(yd,xd,d,priorBeta,...
%           PSI,Omega,OmageInv)
%
% Description:
%
% Calculate the normalization constant due dummy observation prior.
%
% Input:
%
% - T         : Number of observation.
%
% - n         : Number of dependent variables of the VAR.
%
% - p         : Number of lags in the VAR.
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
% - norm : Normalization constant.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [Td,n] = size(yd);

    % Log determinant of prior on Sigma
    if isvector(PSI)
        ldPSI = sum(log(PSI));
    else
        ldPSI = sum(det(PSI));
    end
    
    % Log determinant of prior on Omega
    if isvector(Omega)
        ldOmega = sum(log(Omega));
    else
        ldOmega = log(det(Omega));
    end
    
    % Log determinant of xd'*xd + OmageInv
    ldXXOmageInv = log(det(xd'*xd + OmageInv));
    
    % VAR residuals at the prior mode
    eps = yd - xd*priorBeta;
    
    % log determinant of psi + eps'*eps
    if isvector(PSI)
        PSI = diag(PSI);
    end
    ldPsiEps2 = log(det(PSI + eps'*eps));
    
    % Normalizing constant
    norm = - 0.5*n*Td*log(pi) ...
           + sum(gammaln(0.5*(Td + d - (0:n-1))) - gammaln(0.5*(d - (0:n-1)))) ...
           - 0.5*n*ldOmega + 0.5*d*ldPSI ...
           - 0.5*n*ldXXOmageInv ...
           - 0.5*(Td + d)*ldPsiEps2;

end

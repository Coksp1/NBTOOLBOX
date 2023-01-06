function norm = dummyNormalizationConstant(yd,xd,d,priorBeta,PSI,Omega)
% Syntax:
%
% norm = nb_bVarEstimator.dummyNormalizationConstant(yd,xd,d,priorBeta,...
%           PSI,Omega)
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
% Output:
%
% - norm : Normalization constant.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [Td,n] = size(yd);

    % Log determinant of prior on Sigma
    if isvector(PSI)
        ldPSI = sum(log(PSI));
    else
        ldPSI = sum(det(PSI));
    end
    
    % VAR residuals at the prior mode
    eps = yd - xd*priorBeta;
       
    aaa                  = diag(sqrt(Omega))*(xd'*xd)*diag(sqrt(Omega)); 
    eigaaa               = real(eig(aaa)); 
    eigaaa(eigaaa<1e-12) = 0; 
    eigaaa               = eigaaa + 1;
    
    bbb                  = diag(1./sqrt(PSI))*(eps'*eps)*diag(1./sqrt(PSI));  
    eigbbb               = real(eig(bbb)); 
    eigbbb(eigbbb<1e-12) = 0; 
    eigbbb               = eigbbb + 1;
        
    % Normalizing constant
    norm = - 0.5*n*Td*log(pi) ...
           + sum(gammaln(0.5*(Td + d - (0:n-1))) - gammaln(0.5*(d - (0:n-1)))) ...
           - 0.5*Td*ldPSI ...
           - 0.5*n*sum(log(eigaaa)) ...
           - 0.5*(Td + d)*sum(log(eigbbb));
       

end

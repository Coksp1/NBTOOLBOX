function pY = logMarginalLikelihood(T,n,d,xx,A_prior,A_post,PSI,Omega,eps)
% Syntax:
%
% pY = nb_bVarEstimator.logMarginalLikelihood(T,n,d,xx,A_prior,A_post,...
%           PSI,Omega,eps)
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
% - A_prior   : Prior coefficients.
%
% - A_post    : Posterior coefficients.
%
% - xx        : Calculated as x'x, where x is the regressors of the VAR.
%
% - PSI       : Prior of Sigma.
%
% - Omega     : Scale matrix of the prior of beta.
%
% - eps       : Residuals at posterior 
%
% Output:
%
% - pY : Log marginal likelihood.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Log determinant of prior on Sigma
    if isvector(PSI)
        ldPSI = sum(log(PSI));
    else
        ldPSI = sum(det(PSI));
    end
    
    % Log determinant of scale matrix of the prior of beta and 
    % log determinant of x'*x + OmageInv
    aaa                  = diag(sqrt(Omega))*xx*diag(sqrt(Omega));
    eigaaa               = real(eig(aaa)); 
    eigaaa(eigaaa<1e-12) = 0; 
    eigaaa               = sum(log(eigaaa + 1));
    
    % Log determinant of posterior of Sigma
    bbb                  = diag(1./sqrt(PSI))*(eps'*eps + (A_post - A_prior)'*diag(1./Omega)*(A_post - A_prior))*diag(1./sqrt(PSI));
    eigbbb               = real(eig(bbb)); 
    eigbbb(eigbbb<1e-12) = 0; 
    eigbbb               = sum(log(eigbbb + 1));
    
    % Calculate the marginal likelihood p(Y)
    % T is here actually T-p!
    pY = - 0.5*n*T*log(pi) ...
         + sum(gammaln(0.5*(T + d - (0:n-1))) - gammaln(0.5*(d - (0:n-1)))) ...
         - 0.5*T*ldPSI ...
         - 0.5*n*eigaaa ...
         - 0.5*(T + d)*eigbbb;
       
end

function U = nb_copulacondrnd(M,P,sigma,indC,a,type)
% Syntax:
%
% U = nb_copulacondrnd(M,P,sigma,indC,a,type)
%
% Description:
%
% Generate random variables from the conditional gaussian copula.
% 
% Input:
% 
% - M     : The number of simulated observations of each variables.
%
% - P     : The number of simulated observations of each variables. (Added
%           as a page)
%
% - sigma : The correlation matrix. As a N x N double, with ones along 
%           the diagonal. 
%
% - indC  : Index for the variables to condition on. As a 1 x N or N x 1 
%           logical. sum(indC) must equal Q.
%
% - a     : The values to condition on. As Q x 1 double.
%
% - type  : Set the transformation method to use to transform the rank 
%           correlation coefficients to the linear correlation 
%           coefficients.
%           
%           - 'none'     : If the correlation in the data is calculated
%                          based on the linear correlation coefficients.
%                          Default.
%
%           - 'spearman' : Uses the formula rho = 2.*sin(sigma.*pi./6).
%                          Can be used if the rank correlation coefficients
%                          are calculated based on the data series.
%                          Using the corr(X,'type','spearman') function.
%
%           - 'kendall'  : Uses the formula rho = sin(sigma.*pi./2).
%                          Can be used if the rank correlation coefficients
%                          are calculated based on the data series.
%                          Using the corr(X,'type','kendall') function.
% 
%           The rank correlation coefficients are approximatly invariant
%           to the choice of marginal distribution used to transform the
%           draws from the copula to the draws of the different marginals.
%
% Output:
% 
% - U    : A M x N-Q x P matrix.
%
% Examples:
%
% U = nb_copularnd([1,0.5;0.5,1],'spearman');
%
% See also:
% nb_copula
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'none';
    end

    % Transform the rank correlation to the linear correlation
    switch lower(type) 
        case 'spearman'
            sigma = 2.*sin(sigma.*pi./6);
        case 'kendall'
            sigma = sin(sigma.*pi./2);
    end
    
    % Now we need to partition the correlation matrix
    sigma11   = sigma(~indC,~indC);
    sigma12   = sigma(~indC,indC);
    sigma21   = sigma(indC,~indC);
    sigma22   = sigma(indC,indC);
    
    % Adjust mean given conditional information
    a         = nb_distribution.normal_icdf(a,0,1); % Convert to a value from the normal
    muCond    = sigma12/sigma22*a; 
    
    % Adjust correlation matrix
    sigmaCond = sigma11 - (sigma12/sigma22)*sigma21;
    
    % Generate random variables from the conditional gaussian copula 
    U = nb_mvnrand(M,P,muCond',sigmaCond);
    U = nb_distribution.normal_cdf(U,0,1);
    
end

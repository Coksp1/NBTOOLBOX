function U = nb_copularnd(M,P,sigma,type)
% Syntax:
%
% U = nb_copularnd(M,P,sigma,type)
%
% Description:
%
% Generate random variables from the gaussian copula.
% 
% Input:
% 
% - M     : The number of simulated observations of each variables.
%
% - P     : The number of simulated observations of each variables. (Added
%           as a page)
%
% - sigma : The correlation matrix. As a N x N double, with ones along the
%           diagonal.
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
% - U    : A M x N x P matrix.
%
% Examples:
%
% U = nb_copularnd([1,0.5;0.5,1],'spearman');
%
% See also:
% nb_copula
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

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
    
    % Generate random variables from the gaussian copula 
    U = nb_mvnrand(M,P,zeros(1,size(sigma,1)),sigma);
    U = nb_distribution.normal_cdf(U,0,1);
    
end
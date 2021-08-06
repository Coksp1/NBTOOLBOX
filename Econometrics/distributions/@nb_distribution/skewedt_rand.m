function draws = skewedt_rand(nrow,ncol,a,b,c,d)
% Syntax:
%
% draws = nb_distribution.skewedt_rand(nrow,ncol,a,b,c,d)
%
% Description:
%
% Draw random numbers from the generalized skewed t-distribution.
%
% Caution : This method use the inverse cdf function to produce draws.
%           As the CDF is calculated by MCI it is prone to errors, this
%           may also result in draws that are wrong!
%
% Input:
% 
% - nrow  : Number of rows of the matrix drawn from the distribution
%
% - ncol  : Number of columns of the matrix drawn from the distrubution 
% 
% - a     : The location parameter (mean).
% 
% - b     : The scale parameter.
%
% - c     : The skewness parameter.
%
% - d     : The kurtosis parameter.
%
% Output:
% 
% - draws : A nrow x ncol matrix of random numbers from the distribution  
%
% See also:
% nb_distribution.skewedt_pdf, nb_distribution.skewedt_cdf
%
% Modified by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    p     = rand(nrow,ncol);
    draws = nb_distribution.skewedt_icdf(p,a,b,c,d);
    
end
    


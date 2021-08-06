function draws = normal_rand(nrow,ncol,m,k)
% Syntax:
%
% draws = nb_distribution.normal_rand(nrow,ncol,m,k)
%
% Description:
%
% Draw random numbers from the normal distribution
% 
% Input:
% 
% - nrow  : Number of rows of the matrix drawn from the normal distribution
%
% - ncol  : Number of columns of the matrix drawn from the normal 
%           distrubution 
% 
% - m     : The mean of the distribution
%      
% - k     : The std of the distribution
%
% Output:
% 
% - draws : A nrow x ncol matrix of random numbers from the normal 
%           distribution  
%
% See also:
% nb_distribution.normal_pdf, nb_distribution.normal_cdf
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin ~= 4
        error([mfilename ':: Wrong # of arguments to normal_rand']);
    end;

    draws = randn(nrow,ncol).*k + m;
       
end
    


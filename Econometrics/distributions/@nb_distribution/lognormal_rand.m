function draws = lognormal_rand(nrow,ncol,m,k)
% Syntax:
%
% draws = nb_distribution.lognormal_rand(nrow,ncol,m,k)
%
% Description:
%
% Draw random numbers from the lognormal distribution
% 
% Input:
% 
% - nrow  : Number of rows of the matrix drawn from the lognormal distribution
%
% - ncol  : Number of columns of the matrix drawn from the lognormal 
%           distrubution 
% 
% - m     : A parameter such that the mean of the lognormal is 
%           exp((m+k^2)/2)
% 
% - k     : A parameter such that the mean of the lognormal is k 
%           exp((m+k^2)/2)
%
% Output:
% 
% - draws : A nrow x ncol matrix of random numbers from the lognormal 
%           distribution  
%
% See also:
% nb_distribution.lognormal_pdf, nb_distribution.lognormal_cdf
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin ~= 4
        error([mfilename ':: Wrong # of arguments to lognormal_rand']);
    end;

    draws = exp(randn(nrow,ncol).*k + m);
       
end
    


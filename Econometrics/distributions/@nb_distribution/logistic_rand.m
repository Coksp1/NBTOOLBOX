function draws = logistic_rand(nrow,ncol,m,k)
% Syntax:
%
% draws = nb_distribution.logistic_rand(nrow,ncol,m,k)
%
% Description:
%
% Draw random numbers from the logistic distribution
%
% Input:
% 
% - nrow  : Number of rows of the matrix drawn from the logistic 
%           distribution
%
% - ncol  : Number of columns of the matrix drawn from the logistic 
%           distrubution 
% 
% - m     : The location paramter. Mode = m. Must be a number.
%
% - k     : Scale paramter. Must be a positive number.
%
% Output:
% 
% - draws : A nrow x ncol matrix of random numbers from the logistic 
%           distribution  
%
% See also:
% nb_distribution.logistic_pdf, nb_distribution.logistic_cdf
%
% Modified by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if m <= 0
       error([mfilename ':: Parameter m is wrong'])
    end
    
    p     = rand(nrow,ncol);
    draws = nb_distribution.logistic_icdf(p,m,k);
    
end
    


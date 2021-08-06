function draws = laplace_rand(nrow,ncol,m,k)
% Syntax:
%
% draws = nb_distribution.laplace_rand(nrow,ncol,m,k)
%
% Description:
%
% Draw random numbers from the laplace distribution
%
% Input:
% 
% - nrow  : Number of rows of the matrix drawn from the laplace 
%           distribution
%
% - ncol  : Number of columns of the matrix drawn from the laplace 
%           distrubution 
% 
% - m     : The location paramter. Median = m. Must be a number.
%
% - k     : Scale paramter. Must be a positive number.
%
% Output:
% 
% - draws : A nrow x ncol matrix of random numbers from the laplace 
%           distribution  
%
% See also:
% nb_distribution.laplace_pdf, nb_distribution.laplace_cdf
%
% Modified by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if m <= 0
       error([mfilename ':: Parameter m is wrong'])
    end
    
    p     = rand(nrow,ncol);
    draws = nb_distribution.laplace_icdf(p,m,k);
    
end
    


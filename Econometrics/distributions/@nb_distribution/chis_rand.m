function draws = chis_rand(nrow,ncol,m)
% Syntax:
%
% draws = nb_distribution.chis_rand(nrow,ncol,m)
%
% Description:
%
% Draw random numbers from the chis distribution
%
% Input:
% 
% - nrow  : Number of rows of the matrix drawn from the chis distribution
%
% - ncol  : Number of columns of the matrix drawn from the chis 
%           distrubution 
% 
% - m     : A parameter such that the mean is m
%
% Output:
% 
% - draws : A nrow x ncol matrix of random numbers from the chis 
%           distribution  
%
% See also:
% nb_distribution.chis_pdf, nb_distribution.chis_cdf
%
% Modified by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if m <= 0
       error([mfilename ':: Parameter m is wrong'])
    end
    
    draws = nb_distribution.gamma_rand(nrow,ncol,m*0.5,2);
    
end
    


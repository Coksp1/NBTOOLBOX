function draws = uniform_rand(nrow,ncol,m,k)
% Syntax:
%
% draws = nb_distribution.uniform_rand(nrow,ncol,m,k)
%
% Description:
%
% Draw random numbers from the uniform distribution
% 
% Input:
% 
% - nrow  : Number of rows of the matrix drawn from the uniform 
%           distribution.
%
% - ncol  : Number of columns of the matrix drawn from the uniform 
%           distrubution.
% 
% - m     : Lower limit of the support.
% 
% - k     : Upper limit of the support.
%
% Output:
% 
% - draws : A nrow x ncol matrix of random numbers from the uniform 
%           distribution  
%
% See also:
% nb_distribution.uniform_pdf, nb_distribution.uniform_cdf
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin ~= 4
        error([mfilename ':: Wrong # of arguments to uniform_rand']);
    end;

    draws = m + (k-m).*rand(nrow,ncol);
    
end

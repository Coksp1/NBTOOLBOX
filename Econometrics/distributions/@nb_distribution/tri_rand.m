function draws = tri_rand(nrow,ncol,m,k,d)
% Syntax:
%
% draws = nb_distribution.tri_rand(nrow,ncol,m,k,d)
%
% Description:
%
% Draw random numbers from the triangular distribution
% 
% Input:
% 
% - nrow  : Number of rows of the matrix drawn from the triangular distribution
%
% - ncol  : Number of columns of the matrix drawn from the triangular 
%           distrubution 
% 
% - m     : Lower bound of the triangular distribution.
%
% - k     : Upper bound of the triangular distribution.
%
% - d     : Mode of the triangular distribution.
%
% Output:
% 
% - draws : A nrow x ncol matrix of random numbers from the triangular 
%           distribution  
%
% See also:
% nb_distribution.tri_pdf, nb_distribution.tri_cdf
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin ~= 5
        error([mfilename ':: Wrong # of arguments to tri_rand']);
    end;

    draws = rand(nrow*ncol,1);
    draws = nb_distribution.tri_icdf(draws,m,k,d);
    draws = reshape(draws,[nrow,ncol]);
    
end

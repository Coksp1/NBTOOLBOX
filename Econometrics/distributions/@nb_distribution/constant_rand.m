function draws = constant_rand(nrow,ncol,m)
% Syntax:
%
% draws = nb_distribution.constant_rand(nrow,ncol,m)
%
% Description:
%
% "Draw" random numbers from distribution which always return the same
% number m. Same as repmat(m,nrow,ncol).
%
% Input:
% 
% - nrow  : Number of rows of the matrix of the constant
%
% - ncol  : Number of columns of the matrix of the constant 
% 
% - m     : The constant
%
% Output:
% 
% - draws : A nrow x ncol matrix of the number m
%
% See also:
% nb_distribution.constant_pdf, nb_distribution.constant_cdf
%
% Modified by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    draws = m(ones(nrow,ncol));
    
end
    


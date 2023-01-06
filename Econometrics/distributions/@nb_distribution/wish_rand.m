function A = wish_rand(h,n)
% Syntax:
%
% A = wish_rand(h,n)
%
% Description:
%
% Draws an m x m matrix from a wishart distribution
% with scale matrix h and degrees of freedom nu = n.
% This procedure uses Bartlett's decomposition.
% 
% Note: Parameterized so that mean is n*h
%
% Input:
% 
% - h : m x m scale matrix.
%
% - n : scalar degrees of freedom.
% 
% Output:
% 
% - A : m x m matrix draw from the wishart distribution.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    ch = nb_chol(h,'cov')';
    A  = ch*randn(size(h,1),n);
    A  = A*A';
    
end

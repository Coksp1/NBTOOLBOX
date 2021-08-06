function A = invwish_rand(h,n)
% Syntax:
%
% A = invwish_rand(h,n)
%
% Description:
%
% Draws an m x m matrix from a inverse wishart distribution
% with scale matrix h and degrees of freedom nu = n.
% This procedure uses Bartlett's decomposition.
% 
% Note: Parameterized so that mean is h/n
%
% Input:
% 
% - h : m x m scale matrix.
%
% - n : scalar degrees of freedom.
% 
% Output:
% 
% - A : m x m matrix draw from the inverse wishart distribution.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ch    = nb_chol(h,'cov')';
    x     = randn(n,size(h,1));
    [~,R] = qr(x,0);
    T     = ch/R;
    A     = T*T';
    
end

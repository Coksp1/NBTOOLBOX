function A = invwish_rand(h,n,type)
% Syntax:
%
% A = invwish_rand(h,n)
% A = invwish_rand(h,n,type)
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
% - type : 'cov' or 'covrepair'. See nb_chol
% 
% Output:
% 
% - A : m x m matrix draw from the inverse wishart distribution.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'cov';
    end

    ch    = nb_chol(h,type)';
    x     = randn(n,size(h,1));
    [~,R] = qr(x,0);
    T     = ch/R;
    A     = T*T';
    
end

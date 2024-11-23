function [X,failed] = nb_lyapunovEquation2(A,B,C,tol,maxiter)
% Syntax:
%
% [X,failed] = nb_lyapunovEquation2(A,B,C,tol,maxiter)
%
% Description:
%
% Solve the problem X = A*X*B + C using the fact that:
%
% X = sum A^i*C*B^i over i = 1:inf
%
% This method iterate the sum above until convergence. 
% 
% Input:
% 
% - A       : A symmetric matrix with size N x N
%
% - B       : A symmetric matrix with size N x N
%
% - C       : A symmetric matrix with size N x N
%
% - tol     : The tolerance of the iteration procedure. Default is 
%             eps^(1/3).
%
% - maxiter : Maximum number of iterations. Default is 1000.
% 
% Output:
% 
% - X       : Solution of the problem. As a N x N double.
%
% - failed  : True if the calculation failed.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        maxiter = 1000;
        if nargin < 3
            tol = [];
        end
    end
    
    if isempty(tol)
        tol = eps^(1/3);
    end
    
    if isempty(maxiter)
        maxiter = 1000;
    end
    
    d    = 1000;
    X0   = C;
    iter = 0;
    A0   = A;
    B0   = B;
    while d > tol && iter < maxiter
        
        X     = X0 + A0*X0*B0;
        A     = A0*A0;
        B     = B0*B0;
        d     = abs(X - X0);
        d     = max(d(:));
        X0    = X;
        A0    = A;
        B0    = B;
        iter  = iter + 1;
        
    end
    
    if d <= tol
        failed = 0;
    else
        failed = 1;
    end

end

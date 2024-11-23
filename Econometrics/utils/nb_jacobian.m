function JAC = nb_jacobian(func,x,y)
% Syntax:
%
% JAC = nb_jacobian(func,x,y)
%
% Description:
%
% Calculate the jacobian of the multivariate function func at the point 
% x using a step length x - w. The following formula is used:
%
% JAC(:,j) = (func(x(1),...,x(j),y(j+1),...,y(m)) - 
%            func(x(1),...,x(j-1),y(j),...,y(m)))/(x(j) - y(j))
% 
% Input:
% 
% - func : A MATLAB function handle
%
% - x    : The point of evaluation. As a m x 1 double.
%
% - y    : x + step length. As a m x 1 double.
% 
% Output:
% 
% G      : A m x m double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    m   = size(x,1);
    JAC = nan(m,m);
    for j = 1:m
        xy_j_1   = [x(1:j);y(j+1:end)];
        xy_j     = [x(1:j-1);y(j:end)];
        JAC(:,j) = (func(xy_j_1) - func(xy_j))/(x(j) - y(j));
    end
    
end

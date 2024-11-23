function y = nb_bartlettKernel(x)
% Syntax:
%
% y = nb_bartlettKernel(x)
%
% Description:
%
% Barlett kernel
% 
% Input:
% 
% - x : A double
% 
% Output:
% 
% - y : A double
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    [s1,s2] = size(x);
    x       = x(:);
    ax      = abs(x);
    ind     = ax <= 1;
    y       = zeros(s1*s2,1);
    y(ind)  = 1 - ax(ind);
    y       = reshape(y,s1,s2);
   
end

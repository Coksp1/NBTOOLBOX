function y = nb_parzenKernel(x)
% Syntax:
%
% y = nb_parzenKernel(x)
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [s1,s2] = size(x);
    x       = x(:);
    ax      = abs(x);
    ind1    = ax <= 0.5;
    ind2    = ax <= 1;
    ind3    = ind2 & ~ind1;
    y       = zeros(s1*s2,1);
    y(ind1) = 1 - 6*(x(ind1)).^2 + 6*(ax(ind1).^3);
    y(ind3) = 2*(1 - ax(ind3)).^3;
    y       = reshape(y,s1,s2); 

end

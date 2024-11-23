function y = nb_invpsi(x,err)
% Syntax:
%
% y = nb_invpsi(x,err)
%
% Description:
%
% Inverse of psi function using a newton algorithm.
% 
% Input:
% 
% - x   : A double.
% 
% - err : The stopping criterion for the newton algorithm.
%
% Output:
% 
% - y   : A double.
%
% See also:
% psi
%
% Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        err = eps^(1/2);
    end
    
    if x >= -2.22
        y = exp(x) + 1/2;
    else
        y = -1/(x + psi(1));
    end
    
    y_diff = inf;
    while abs(y_diff) > err
        y_update = y - (psi(y) - x)/psi(1,y);
        y_diff   = y - y_update;
        y        = y_update;
    end
  
end

function G = nb_gradient(func,x,h)
% Syntax:
%
% G = nb_gradient(func,x,h)
%
% Description:
%
% Calculate the gradient of the multivariate function func at the point 
% x using a step length h.
%
% See Abramowitz and Stegun (1965) formulas 25.3.21.
% 
% Input:
% 
% - func : A MATLAB function handle
%
% - x    : The point of evaluation. As a n x 1 double.
%
% - h    : Step length. Either a 1x1 double or a n x 1 double. Default
%          is abs(x)*eps^(1/6).
% 
% Output:
% 
% G      : A n x 1 double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        h = [];
    end

    x = x(:);
    n = size(x,1);
    if isempty(h)
        h       = abs(x)*eps^(1/6);
        h(x==0) = eps^(1/6);
    else
        if isscalar(h)
            h = h*ones(n,1);
        end
    end

    % Calculate the first order derivative wrt one element
    fLead = x;
    fLag  = x;
    xt    = x;
    for ii = 1:n 
        xt(ii)    = x(ii) + h(ii);
        fLead(ii) = func(xt);
        xt(ii)    = x(ii) - h(ii);
        fLag(ii)  = func(xt);
        xt(ii)    = x(ii); 
    end
    G = (fLead - fLag)./(2*h);
    
end

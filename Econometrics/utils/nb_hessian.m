function H = nb_hessian(func,x,h)
% Syntax:
%
% H = nb_hessian(func,x,h)
%
% Description:
%
% Calculate the hessian of the multivariate function func at the point 
% x using a step length h.
%
% See Abramowitz and Stegun (1965) formulas 25.3.23 and 25.3.27.
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
% H      : A n x n double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        h = [];
    end

    x = x(:);
    n = size(x,1);
    if isempty(h)
        h = abs(x)*eps^(1/6);
    else
        if isscalar(h)
            h = h*ones(n,1);
        end
    end

    % Calculate the second order derivative wrt one element
    f     = func(x);
    f     = ones(n,1)*f;
    fLead = f;
    fLag  = f;
    xt    = x;
    for ii = 1:n
        
        xt(ii)    = x(ii) + h(ii);
        fLead(ii) = func(xt);
        xt(ii)    = x(ii) - h(ii);
        fLag(ii)  = func(xt);
        xt(ii)    = x(ii); 
        
    end
    Hdiag = (fLead - 2*f + fLag)./(h.^2);
    Hdiag = diag(Hdiag);
    
    % Calculate the cross derivatives
    H   = zeros(n,n);
    xt_ = x;
    for ii = 1:n
        
        for jj = ii+1:n
            
            ind      = [ii,jj];
            xt(ind)  = x(ind) + h(ind);
            xt_(ind) = x(ind) - h(ind);
            fLead2   = func(xt);
            fLag2    = func(xt_);
            xt(ind)  = x(ind);
            xt_(ind) = x(ind);
            H(ii,jj) = -(sum(fLead(ind)) + sum(fLag(ind)) - 2*f(1) - fLead2 - fLag2)/(2*h(ii)*h(jj));  
            
        end
        
    end
    
    H = H + H';
    H = H + Hdiag; 

end

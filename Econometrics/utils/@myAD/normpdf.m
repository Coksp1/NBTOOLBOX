function x = normpdf(x,m,k)
% Syntax:
%
% x = normcdf(x,m,k)
%
% Description:
%
% Normal cdf.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        k = 1;
        if nargin < 2
            m = 0;
        end
    end

    x.derivatives = valXder(normal_deriv(x.values(:),m,k), x.derivatives);
    x.values      = nb_distribution.normal_pdf(x.values,m,k);
    
end

function x = normal_deriv(x,m,k)
    x = -((x-m)/(sqrt(2*pi)*k^3))*exp(-0.5*((x - m)./k).^2);
end

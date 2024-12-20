function x = normcdf(x,m,k)
% Syntax:
%
% x = normcdf(x,m,k)
%
% Description:
%
% Normal cdf.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        k = 1;
        if nargin < 2
            m = 0;
        end
    end

    x.derivatives = valXder(nb_distribution.normal_pdf(x.values(:),m,k), x.derivatives);
    x.values      = nb_distribution.normal_cdf(x.values,m,k);
    
end

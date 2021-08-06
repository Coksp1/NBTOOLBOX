function x = logncdf(x,m,k)
% Syntax:
%
% x = logncdf(x,m,k)
%
% Description:
%
% Log normal cdf.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x.derivatives = valXder(nb_distribution.lognormal_pdf(x.values(:),m,k), x.derivatives);
    x.values      = nb_distribution.lognormal_cdf(x.values,m,k);
    
end

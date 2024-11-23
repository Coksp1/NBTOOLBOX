function f = wald_pdf(x,m,k)
% Syntax:
%
% f = nb_distribution.wald_pdf(x,m,k)
%
% Description:
%
% PDF of the wald distribution
% 
% Input:
% 
% - x : The point to evaluate the cdf, as a double
%
% - m : The first parameter of the wald distribution. Must be a 1x1 double
%       greater than 0. E[X] = m.
% 
% - k : The second parameter of the wald distribution. Must be a 1x1 double
%       greater than 0.
%
% Output:
% 
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.wald_cdf, nb_distribution.wald_rand,
% nb_distribution.wald_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    f = sqrt(k./(2.*pi.*(x.^3))).*exp((-k.*(x - m).^2)./(2.*m^2.*x));
    
end

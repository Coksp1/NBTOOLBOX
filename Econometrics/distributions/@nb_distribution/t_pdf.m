function f = t_pdf(x,m,a,b)
% Syntax:
%
% f = nb_distribution.t_pdf(x,m)
% f = nb_distribution.t_pdf(x,m,a,b)
%
% Description:
%
% PDF of the student-t distribution
% 
% Input:
% 
% - x : The point to evaluate the pdf, as a double
%
% - m : The number of degrees of freedom. Must be positive.
%
% - a : The location parameter. Optional. Default is 0.
%
% - b : The scale parameter. Must be > 0. Optional. Default is 1.
% 
% Output:
% 
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.t_cdf, nb_distribution.t_rand, 
% nb_distribution.t_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        b = 1;
        if nargin < 3
            a = 0;
        end
    end

    %f = gamma((m+1)/2)./sqrt(m*pi)./gamma(m/2).*(1+x.^2./m).^(-(m+1)/2);
    x = (x - a)/b;
    f = (1/(b*sqrt(m)*beta(0.5,m/2)))*(1 + (x.^2)/m).^(-(m+1)/2);
     
end

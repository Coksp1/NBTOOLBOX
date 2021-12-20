function f = t_cdf(x,m,a,b)
% Syntax:
%
% f = nb_distribution.t_cdf(x,m)
% f = nb_distribution.t_cdf(x,m,a,b)
%
% Description:
%
% CDF of the student-t distribution.
% 
% Input:
% 
% - x : The point to evaluate the cdf, as a double
%
% - m : The number of degrees of freedom. Must be positive.
%
% - a : The location parameter. Optional. Default is 0.
%
% - b : The scale parameter. Must be > 0. Optional. Default is 1.
%
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.t_pdf, nb_distribution.t_rand,
% nb_distribution.t_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        b = 1;
        if nargin < 3
            a = 0;
        end
    end

    x      = (x - a)/b;
    [T, ~] = size(x);
    neg    = x < 0;
    f      = nb_distribution.f_cdf(x.^2,1,m);
    iota   = ones(T,1);
    out    = iota - (iota - f)/2;
    f      = out + (iota - 2*out).*neg;

end

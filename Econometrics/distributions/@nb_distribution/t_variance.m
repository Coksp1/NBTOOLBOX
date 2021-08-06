function x = t_variance(m,~,b)
% Syntax:
%
% x = nb_distribution.t_variance(m)
% x = nb_distribution.t_variance(m,a,b)
%
% Description:
%
% Variance of the student-t  distribution. Only defined for m > 1.
% Will return nan otherwise.
% 
% Input:
% 
% - m : The number of degrees of freedom. Must be positive.
%
% - a : The location parameter. Optional. Default is 0.
%
% - b : The scale parameter. Must be > 0. Optional. Default is 1.
% 
% Output:
% 
% - x : The variance of the student-t distribution
%
% See also:
% nb_distribution.t_mode, nb_distribution.t_median, 
% nb_distribution.t_mean
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        b = 1;
    end

    if m > 2
        x = (b^2)*m/(m-2);
    elseif m > 1
        x = inf;
    else
        x = nan;
    end

end

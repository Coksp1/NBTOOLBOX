function x = t_std(m,a,b)
% Syntax:
%
% x = nb_distribution.t_std(m)
% x = nb_distribution.t_std(m,a,b)
%
% Description:
%
% Standard deviation of the student-t distribution. Only defined for m > 2.
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
% - x : The standard deviation of the student-t distribution
%
% See also:
% nb_distribution.t_mode, nb_distribution.t_median, 
% nb_distribution.t_mean, nb_distribution.t_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        b = 1;
        if nargin < 2
            a = 0;
        end
    end

    x = sqrt(nb_distribution.t_variance(m,a,b));

end

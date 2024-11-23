function x = t_mean(m,a,~)
% Syntax:
%
% x = nb_distribution.t_mean(m)
% x = nb_distribution.t_mean(m,a,b)
%
% Description:
%
% Mean of the student-t distribution. Only defined for m > 1, otherwise 
% not defined (will return nan).
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
% - x : The mean of the student-t distribution
%
% See also:
% nb_distribution.t_mode, nb_distribution.t_median, 
% nb_distribution.t_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        a = 0;
    end

    if m > 1
        x = a;
    else
        x = nan;
    end

end

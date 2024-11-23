function x = t_median(~,a,~)
% Syntax:
%
% x = nb_distribution.t_median(m)
% x = nb_distribution.t_median(m,a,b)
%
% Description:
%
% Median of the student-t distribution
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
% - x : The median of the student-t distribution
%
% See also:
% nb_distribution.t_mode, nb_distribution.t_mean, 
% nb_distribution.t_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        a = 0;
    end
    x = a;

end

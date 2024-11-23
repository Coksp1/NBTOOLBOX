function x = t_mode(~,a,~)
% Syntax:
%
% x = nb_distribution.t_mode(m)
% x = nb_distribution.t_mode(m,a,b)
%
% Description:
%
% Mode of the student-t distribution.
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
% - x : The mode of the student-t distribution
%
% See also:
% nb_distribution.t_median, nb_distribution.t_mean, 
% nb_distribution.t_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        a = 0;
    end
    x = a;

end

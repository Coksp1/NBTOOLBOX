function x = t_skewness(m,~,~)
% Syntax:
%
% x = nb_distribution.t_skewness(m)
% x = nb_distribution.t_skewness(m,a,b)
%
% Description:
%
% Skewness of the student-t distribution. Only defined for m > 3. Will
% return nan otherwise.
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
% - x : The skewness of the student-t distribution
%
% See also:
% nb_distribution.t_median, nb_distribution.t_mean, 
% nb_distribution.t_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if m > 3
        x = 0;
    else
        x = nan;
    end

end

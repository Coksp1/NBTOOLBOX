function x = t_kurtosis(m,~,~)
% Syntax:
%
% x = nb_distribution.t_kurtosis(m)
% x = nb_distribution.t_kurtosis(m,a,b)
%
% Description:
%
% Kurtosis of the student-t distribution. Only defined for m > 2, 
% otherwise not defined (will return nan).
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
% - x : The kurtosis of the student-t distribution
%
% See also:
% nb_distribution.f_median, nb_distribution.f_mean, 
% nb_distribution.f_variance, nb_distribution.f_skewness
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if m > 4
        x = 6/(m - 4) + 3;
    elseif m > 2
        x = inf;
    else
        x = nan;
    end

end

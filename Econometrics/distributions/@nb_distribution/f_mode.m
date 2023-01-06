function x = f_mode(m,k)
% Syntax:
%
% x = nb_distribution.f_mode(m,k)
%
% Description:
%
% Mode of the F(m,k) distribution. Only defined for m > 2, otherwise 
% not defined (will return nan).
% 
% Input:
% 
% - m : First parameter of the distribution. Must be positive
% 
% - k : Second parameter of the distribution. A parameter such that the 
%       mean of the F-distribution is equal to k/(k-2) for k > 2. Must be
%       positive.
%
% Output:
% 
% - x : The mode of the F(m,k) distribution
%
% See also:
% nb_distribution.f_median, nb_distribution.f_mean, 
% nb_distribution.f_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if m > 2
        x = k/(k+2)*((m - 2)/m);
    else
        x = nan;
    end

end

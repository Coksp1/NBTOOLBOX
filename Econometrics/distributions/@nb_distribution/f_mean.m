function x = f_mean(~,k)
% Syntax:
%
% x = nb_distribution.f_mean(m,k)
%
% Description:
%
% Mean of the F(m,k) distribution. Only defined for k > 2, otherwise 
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
% - x : The mean of the F(m,k) distribution
%
% See also:
% nb_distribution.f_mode, nb_distribution.f_median, 
% nb_distribution.f_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if k > 2
        x = k/(k-2);
    else
        x = nan;
    end

end

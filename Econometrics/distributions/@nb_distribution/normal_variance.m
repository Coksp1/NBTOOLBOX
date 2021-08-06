function x = normal_variance(~,k)
% Syntax:
%
% x = nb_distribution.normal_variance(m,k)
%
% Description:
%
% Variance of the normal distribution
% 
% Input:
% 
% - m : A parameter such that the mean of the normal = m
% 
% - k : A parameter such that the std of the normal = k
%
% Output:
% 
% - x : The variance of the normal distribution
%
% See also:
% nb_distribution.normal_mean, nb_distribution.normal_std
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = k^2;

end

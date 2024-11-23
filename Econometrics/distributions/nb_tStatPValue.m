function p = nb_tStatPValue(x,m)
% Syntax:
%
% p = nb_tStatPValue(x,m)
%
% Description:
%
% P-value of t-statistics.
% 
% Input:
% 
% - x : The point to evaluate the t-statistics at, as a double.
%
% - m : The number of degrees of freedom. Must be positive.
%
% Output:
% 
% - p : P-value of t-statistics, same size as x.
%
% See also:
% nb_distribution.t_pdf, nb_distribution.t_rand,
% nb_distribution.t_icdf, nb_distribution.t_cdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    p = (1 - nb_distribution.t_cdf(x,m))*2;
    
end

function x = ast_median(a,b,c,d,e)
% Syntax:
%
% x = nb_distribution.ast_median(a,b,c,d,e)
%
% Description:
%
% Median of the asymmetric t-distribution of Zhu and Galbraith (2009).
% 
% Input:
% 
% - a : The location parameter.
% 
% - b : The scale parameter.
%
% - c : The skewness parameter.
%
% - d : The left parameter (>0). 
%
% - e : The right parameter (>0).
%
% Output:
% 
% - x : The median of the distribution
%
% See also:
% nb_distribution.ast_mode, nb_distribution.ast_mean, 
% nb_distribution.ast_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = nb_distribution.ast_icdf(0.5,a,b,c,d,e);

end

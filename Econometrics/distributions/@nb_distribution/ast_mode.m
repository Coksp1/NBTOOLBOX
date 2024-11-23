function x = ast_mode(a,~,~,~,~)
% Syntax:
%
% x = nb_distribution.ast_mode(a,b,c,d,e)
%
% Description:
%
% Mode of the asymmetric t-distribution of Zhu and Galbraith (2009).
% 
% Input:
% 
% - a : The location parameter.
% 
% - b : The scale parameter (>0).
%
% - c : The skewness parameter (1>c>0).
%
% - d : The left parameter (>0). 
%
% - e : The right parameter (>0).
%
% Output:
% 
% - x : The mode of the distribution
%
% See also:
% nb_distribution.ast_median, nb_distribution.ast_mean, 
% nb_distribution.ast_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x = a;

end

function x = ast_variance(~,b,c,d,e)
% Syntax:
%
% x = nb_distribution.ast_variance(a,b,c,d,e)
%
% Description:
%
% Variance of the asymmetric t-distribution of Zhu and Galbraith (2009).
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
% - x : The variance of the distribution
%
% See also:
% nb_distribution.ast_mode, nb_distribution.ast_median, 
% nb_distribution.ast_mean
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if d > 2 && e > 2
        x = centered_variance(c,d,e);
        x = x.*(b^2);
    else
        x = nan;
    end
    
end

function x = centered_variance(c,d,e)

    cstar = nb_ast_cstar(c,d,e);
    if cstar == 1
        x = nb_distribution.t_variance(d);
    elseif cstar == 0
        x = nb_distribution.t_variance(e);
    else
        B     = nb_ast_b(c,d,e);
        x1    = 4*c*cstar^2*(d/(d - 2)) + 4*(1 - c)*(1 - cstar)*e/(e - 2);
        x2    = cstar^2*(d/(d - 1));
        x3    = (1 - cstar)^2*(e/(e - 1));
        x4    = 4*B*(-x2 + x3);
        x     = x1 - x4^2;
    end
    
end

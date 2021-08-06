function x = ast_mean(a,b,c,d,e)
% Syntax:
%
% x = nb_distribution.ast_mean(a,b,c,d,e)
%
% Description:
%
% Mean of the asymmetric t-distribution of Zhu and Galbraith (2009).
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
% - x : The mean of the distribution
%
% See also:
% nb_distribution.ast_mode, nb_distribution.ast_median, 
% nb_distribution.ast_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = centered_mean(c,d,e);
    x = x.*b + a;
    
end

function x = centered_mean(c,d,e)

    cstar = nb_ast_cstar(c,d,e);
    if cstar == 0 || cstar == 1 % Symmetric distribution!
        x  = 0; 
    else
        B  = nb_ast_b(c,d,e);
        x1 = cstar^2*(d/(d - 1));
        x2 = (1 - cstar)^2*(e/(e - 1));
        x  = 4*B*(-x1 + x2);
    end
    
end

function f = ast_cdf(x,a,b,c,d,e)
% Syntax:
%
% f = nb_distribution.ast_cdf(x,a,b,c,d,e)
%
% Description:
%
% CDF of the asymmetric t-distribution of Zhu and Galbraith (2009).
% 
% Input:
% 
% - x : The point to evaluate the cdf, as a double.
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
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.ast_pdf, nb_distribution.ast_rand,
% nb_distribution.ast_icdf, nb_mci
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    y = (x - a)./b; % Standardize
    f = centered_cdf(y,c,d,e);
    
end

function f = centered_cdf(y,c,d,e)

    cstar = nb_ast_cstar(c,d,e);
    if cstar == 1
        f     = nb_distribution.t_cdf(y,d);
    elseif cstar == 0
        f     = nb_distribution.t_cdf(y,e);
    else
        f1    = min(y,0)./(2*cstar);
        f2    = max(y,0)./(2*(1 - cstar));
        f     = 2*c*nb_distribution.t_cdf(f1,d) + 2*(1 - c)*(nb_distribution.t_cdf(f2,e) - 0.5);
    end

end

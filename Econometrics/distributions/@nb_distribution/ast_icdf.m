function x = ast_icdf(p,a,b,c,d,e)
% Syntax:
%
% x = nb_distribution.ast_icdf(p,a,b,c,d,e)
%
% Description:
%
% Returns the inverse of the cdf at p of the asymmetric t-distribution of 
% Zhu and Galbraith (2009).
%
% Input:
% 
% - p : A vector of probabilities
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
% - x : A double with the quantile at each element of p of the gamma(m,k) 
%       distribution
%
% See also:
% nb_distribution.ast_cdf, nb_distribution.ast_rand, 
% nb_distribution.ast_pdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if any(abs(2*p(:)-1) > 1)
        error([mfilename ':: a probability should be between 0 and 1'])
    end
    y = centered_icdf(p,c,d,e);
    x = y.*b + a; % Scale and locate
    
end

function f = centered_icdf(y,c,d,e)

    cstar = nb_ast_cstar(c,d,e);
    if cstar == 0
        f  = nb_distribution.t_icdf(y,e);
    elseif cstar == 1
        f  = nb_distribution.t_icdf(y,d);
    else
        f1 = min(y,c)./(2*c);
        f2 = (max(y,c) + 1 - 2*c)./(2*(1 - c));
        f  = 2*cstar*nb_distribution.t_icdf(f1,d) + 2*(1 - cstar)*nb_distribution.t_icdf(f2,e);
    end
    
end
    

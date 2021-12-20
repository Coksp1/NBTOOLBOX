function f = ast_pdf(x,a,b,c,d,e)
% Syntax:
%
% f = nb_distribution.ast_pdf(x,a,b,c,d,e)
%
% Description:
%
% PDF of the asymmetric t-distribution of Zhu and Galbraith (2009).
% 
% Input:
% 
% - x : The point to evaluate the pdf, as a double
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
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.ast_cdf, nb_distribution.ast_rand, 
% nb_distribution.ast_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    y = (x - a)./b; % Standardize
    f = (1/b)*centered_pdf(y,c,d,e);
    
end

function f = centered_pdf(y,c,d,e)

    cstar = nb_ast_cstar(c,d,e);
    if cstar == 0
        f = nb_distribution.t_pdf(y,e);
    elseif cstar == 1
        f = nb_distribution.t_pdf(y,d);
    else
        f       = y;
        f(y<=0) = (c/cstar)*nb_ast_k(d).*(1 + (1/d).*(y(y<=0)./(2*cstar)).^2).^(-(d+1)/2); 
        f(y>0)  = ((1 - c)/(1 - cstar))*nb_ast_k(e).*(1 + (1/e).*(y(y>0)./(2*(1 - cstar))).^2).^(-(e+1)/2); 
    end
    
end

function x = t_icdf(p,m,a,b)
% Syntax:
%
% x = nb_distribution.t_icdf(p,m)
% x = nb_distribution.t_icdf(p,m,a,b)
%
% Description:
%
% Returns the inverse of the cdf at p of the student-t distribution
% 
% Input:
% 
% - p : A vector of probabilities
%
% - m : The number of degrees of freedom. Must be positive.
%
% - a : The location parameter. Optional. Default is 0.
%
% - b : The scale parameter. Must be > 0. Optional. Default is 1.
% 
% Output:
% 
% - x : A double with the quantile at each element of p of the student-t 
%       distribution
%
% See also:
% nb_distribution.t_cdf, nb_distribution.t_rand, 
% nb_distribution.t_pdf
%
% Written by Kenneth Sæterhagen Paulsen   

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        b = 1;
        if nargin < 3
            a = 0;
        end
    end

    if any(abs(2*p(:)-1) > 1)
        error([mfilename ':: The probabilities must be between 0 and 1'])
    end

    pt = p;
    s  = p < 0.5; 
    p  = p + (1-2*p).*s;
    p  = 1 - (2*(1 - p));
    try
        x = nb_distribution.beta_icdf(p,1/2,m/2);
        x = x.*m./((1-x));
        x = (1 - 2*s).*sqrt(x);
    catch %#ok<CTCH>
        opt = nb_getOpt();
        x   = pt;
        for ii = 1:length(pt)
            [x(ii),~,e] = fminsearch(@pFinder,0.5,opt,m,a,b,pt(ii)); 
        end
        nb_interpretExitFlag(e,'fminsearch');
    end
    
    x(p==0) = zeros;
    x(p==1) = inf;
    x       = a + x*b;
    
end

function f = pFinder(x,m,a,b,p)
    f = (nb_distribution.t_cdf(x,m,a,b) - p)^2;
end    

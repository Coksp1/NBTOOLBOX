function f = skewedt_cdf(x,a,b,c,d)
% Syntax:
%
% f = nb_distribution.skewedt_cdf(x,a,b,c,d)
%
% Description:
%
% CDF of the generalized skewed t-distribution.
%
% Caution : Calculated using monte carlo integration. This may induce
%           numerical problems with calculating the CDF of this
%           distribution.
% 
% Input:
% 
% - x : The point to evaluate the cdf, as a double.
%
% - a : The location parameter (mean).
% 
% - b : The scale parameter.
%
% - c : The skewness parameter.
%
% - d : The kurtosis parameter.
%
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.skewedt_pdf, nb_distribution.skewedt_rand,
% nb_distribution.skewedt_icdf, nb_mci
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    dist       = nb_distribution('type','normal','parameters',{a,b});
    [s1,s2,s3] = size(x);
    f          = nan(s1,s2,s3);
    for rr = 1:s1
        for cc = 1:s2
            for pp = 1:s3
                if x(rr,cc,pp) == -inf
                    f(rr,cc,pp) = 0;
                else
                    f(rr,cc,pp) = nb_mci(@(x)nb_distribution.skewedt_pdf(x,a,b,c,d),-inf,x(rr,cc,pp),10000,dist);
                end
            end
        end
    end
    f(f<0) = 0;
    f(f>1) = 1;
    
end

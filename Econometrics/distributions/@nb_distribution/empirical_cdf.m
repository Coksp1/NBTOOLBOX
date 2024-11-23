function  f = empirical_cdf(x,domain,CDF)
% Syntax:
%
% f = nb_distribution.empirical_cdf(x,domain,density)
%
% Description:
%
% CDF of the (Kaplan-Meier) cumulative distribution function. To get the
% CDF of a point in between two points of the domain, a linear 
% interpolation method is used.
% 
% Input:
% 
% - x       : The points to evaluate the cdf, as a double (max dim is 3)
%
% - domain  : The domain of the CDF.
% 
% - CDF     : The emprirical cumulative density function.
%
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.empirical_pdf, nb_distribution.empirical_rand,
% nb_distribution.empirical_icdf
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Then we linear interpolate the wanted point and the two closest point
    % in the domain
    [z,ind]    = sort(x,1);
    [s1,s2,s3] = size(x);
    f          = nan(s1,s2,s3);
    for jj = 1:s3
        for ii = 1:s2
            f(:,ii,jj) = interp1(domain,CDF,z(:,ii,jj),'linear');
        end
    end
    
    % Reoder back again
    f(ind)  = f;
    ind1    = isnan(f) & x < domain(round(length(domain)/2));
    f(ind1) = 0;
    ind2    = isnan(f) & x > domain(round(length(domain)/2));
    f(ind2) = 1;
    
end








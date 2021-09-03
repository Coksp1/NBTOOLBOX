function f = kernel_cdf(x,domain,density)
% Syntax:
%
% f = nb_distribution.kernel_cdf(x,domain,density)
%
% Description:
%
% CDF of the estimated kernel density. To get the CDF of a point in between
% two points of the domain, a linear interpolation method is used.
% 
% Input:
% 
% - x       : The points to evaluate the cdf, as a double (max dim is 3)
%
% - domain  : The domain of the distribution
% 
% - density : The density of the distribution
%
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.kernel_pdf, nb_distribution.kernel_rand,
% nb_distribution.kernel_icdf
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    binsL = domain(2) - domain(1);
    CDF   = cumsum(density*binsL); 
    
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
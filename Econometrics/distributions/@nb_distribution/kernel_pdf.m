function f = kernel_pdf(x,domain,density)
% Syntax:
%
% f = nb_distribution.kernel_pdf(x,domain,density)
%
% Description:
%
% PDF of the estimated kernel density. To get the PDF of a point in between
% two points of the domain, a linear interpolation method is used.
% 
% Input:
% 
% - x       : The points to evaluate the pdf, as a double
%
% - domain  : The domain of the distribution
% 
% - density : The density of the distribution
%
% Output:
% 
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.kernel_cdf, nb_distribution.kernel_rand,
% nb_distribution.kernel_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Then we linear interpolate the wanted point and the two closest point
    % in the domain
    [x,ind]    = sort(x,1);
    [s1,s2,s3] = size(x);
    f          = nan(s1,s2,s3);
    for jj = 1:s3
        for ii = 1:s2
            f(:,ii,jj) = interp1(domain,density,x(:,ii,jj),'linear');
        end
    end
    
    % Reoder back again
    f(ind)      = f;
    f(isnan(f)) = 0;
    
end

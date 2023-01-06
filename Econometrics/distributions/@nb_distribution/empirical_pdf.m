function f = empirical_pdf(x,domain,CDF)
% Syntax:
%
% f = nb_distribution.empirical_pdf(x,domain,CDF)
%
% Description:
%
% PDF of the estimated empirical density. To get the PDF of a point in between
% two points of the domain, a linear interpolation method is used.
% 
% Input:
% 
% - x       : The points to evaluate the pdf, as a double.
%
% - domain  : The domain of the distribution.
% 
% - density : The empirical CDF.
%
% Output:
% 
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.empirical_cdf, nb_distribution.empirical_rand,
% nb_distribution.empirical_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Find the PDF
    diffR   = (domain(end)-domain(1))/length(domain);
    tempDom = transpose(domain(1):diffR:domain(end));
    newCdf  = nb_distribution.empirical_cdf(tempDom,domain,CDF);
    PDF     = diff(newCdf(2:end))./diff(tempDom(2:end));
    
    % Then we linear interpolate the wanted point and the two closest point
    % in the domain
    [x,ind]    = sort(x,1);
    [s1,s2,s3] = size(x);
    f          = nan(s1,s2,s3);
    for jj = 1:s3
        for ii = 1:s2
            f(:,ii,jj) = interp1(tempDom(2:end),PDF,x(:,ii,jj),'linear');
        end
    end
    
    % Reoder back again
    f(ind)      = f;
    f(isnan(f)) = 0;
    
end


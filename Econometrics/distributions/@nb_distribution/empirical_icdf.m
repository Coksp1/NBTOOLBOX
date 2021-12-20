function x = empirical_icdf(p,domain,CDF)
% Syntax:
%
% x = nb_distribution.empirical_icdf(p,domain,CDF)
%
% Description:
%
% Inverse CDF of the estimated empirical distribution. Uses the mean of the
% two closest points in the domain.
% 
% Input:
% 
% - p       : A vector of probabilities
%
% - domain  : The domain of the distribution
% 
% - CDF     : The cumulative density function
%
% Output:
% 
% - x : The inverse CDF at the evaluated probabilities, same size as p.
%
% See also:
% nb_distribution.empirical_pdf, nb_distribution.empirical_rand,
% nb_distribution.empirical_cdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if any(abs(2*p(:)-1) > 1)
        error([mfilename ':: a probability should be between 0 and 1'])
    end

    [s1,s2,s3] = size(p);
    
    p     = p(:); 
    n     = length(p);
    nd    = length(domain);
    x     = nan(n,1);
    for ii = 1:n
        [~,I] = sort([p(ii);CDF]);
        ind   = find(1==I,1);
        if ind == 1
            x(ii) = domain(1);
        elseif ind == nd + 1 || ind == nd
            x(ii) = domain(end);
        else
            x(ii) = (domain(I(ind-1)) + domain(I(ind+1)))/2;
        end
    end
    
    x = reshape(x,[s1,s2,s3]);
    
end

function x = empirical_mode(domain,density)
% Syntax:
%
% x = nb_distribution.empirical_mode(domain,density)
%
% Description:
%
% The mode is found by finding the max point of the estimated PDF of the
% empirical CDF, and return the matching point in its domain.
% 
% Input:
% 
% - domain  : The domain of the distribution.
% 
% - density : The cumulative density function of the distribution.
%
% Output:
% 
% - x : The kurtosis of the estimated PDF of the empirical CDF density
%
% See also:
% nb_distribution.empirical_median, nb_distribution.empirical_mean, 
% nb_distribution.empirical_variance, nb_distribution.empirical_rand
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Find the PDF
    diffR   = (domain(end)-domain(1))/length(domain);
    tempDom = transpose(domain(1):diffR:domain(end));
    newCdf  = nb_distribution.empirical_cdf(tempDom,domain,density);
    density = diff(newCdf(2:end))./diff(tempDom(2:end));
    [~,ind] = max(density);
    x       = tempDom(ind);
    
end

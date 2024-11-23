function x = kernel_icdf(p,domain,density)
% Syntax:
%
% x = nb_distribution.kernel_icdf(p,domain,density)
%
% Description:
%
% Inverse CDF of the estimated kernel distribution. Uses the mean of the
% two closest points in the domain.
% 
% Input:
% 
% - p       : A vector of probabilities
%
% - domain  : The domain of the distribution
% 
% - density : The density of the distribution
%
% Output:
% 
% - x : The inverse CDF at the evaluated probabilities, same size as p.
%
% See also:
% nb_distribution.kernel_pdf, nb_distribution.kernel_rand,
% nb_distribution.kernel_cdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if any(abs(2*p(:)-1) > 1)
        error([mfilename ':: a probability should be between 0 and 1'])
    end

    [s1,s2,s3] = size(p);
    
    p     = p(:);
    binsL = domain(2) - domain(1);
    CDF   = cumsum(density)*binsL; 
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

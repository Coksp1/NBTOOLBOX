function domain = empirical_domain(domain,~)
% Syntax:
%
% f = nb_distribution.empirical_domain(domain)
%
% Description:
%
% Get the domain of the distribution
% 
% Input:
% 
% - domain  : The domain of the distribution
%
% Output:
% 
% - domain : A 1x2 double with the lower and upper limits of the domain.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    domain = [min(domain),max(domain)];
    
end

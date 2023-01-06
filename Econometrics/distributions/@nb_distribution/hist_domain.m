function domain = hist_domain(a)
% Syntax:
%
% f = nb_distribution.hist_domain(a)
%
% Description:
%
% Get the domain of the histogram, i.e. min and max of the empirical data.
% 
% Input:
%
% - a : The data points.
%
% Output:
% 
% - domain : A 1x2 double with the lower and upper limits of the domain.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    domain = [min(a),max(a)];
    
end

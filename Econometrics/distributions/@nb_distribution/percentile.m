function x = percentile(obj,perc)
% Syntax:
%
% x = percentile(obj,perc)
%
% Description:
%
% Get the wanted percentiles of the distribution(s). Same as icdf.
% 
% Input:
% 
% - obj  : A vector of nb_distribution objects
% 
% - perc : 1 x nPerc double with the wanted percentiles. E.g. [10,90]
%
% Output:
% 
% - x    : A nPerc x nobj double
%
% Examples:
%
% obj(2) = nb_distribution('type','normal','parameters',{0,2})
% x      = percentile(obj,[10,90])
%
% See also:
% nb_distribution.icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = icdf(obj,perc/100);

end

function obj = cumpcn(obj,stripNaN)
% Syntax:
%
% obj = cumpcn(obj)
% obj = cumpcn(obj,stripNaN)
%
% Description:
%
% Calculate percentage cumulative approx growth, using the formula: 
% 100*(log(x(t))-log(x(0))) of all the timeseries of the nb_math_ts object.
% 
% Input:
% 
% - obj      : An object of class nb_math_ts
% 
% - stripNaN : Strip nan before calculating the percentage cumulative 
%              growth rates.
% 
% Output:
% 
% - obj      : An nb_math_ts object with the calculated timeseries stored.
% 
% Examples:
%
% obj = cumpcn(obj);
% obj = cumpcn(obj,true);
%
% See also:
% pcn, icumpcn
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        stripNaN = false;
    end
    obj.data = nb_cumpcn(obj.data,stripNaN);

end

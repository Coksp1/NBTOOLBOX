function obj = cumdiff(obj,stripNaN)
% Syntax:
%
% obj = cumdiff(obj)
% obj = cumdiff(obj,stripNaN)
%
% Description:
%
% Calculate diff, using the formula: x(t)-x(0) of all the timeseries of 
% the nb_ts object.
% 
% Input:
% 
% - obj      : An object of class nb_ts
% 
% - stripNaN : Strip nan before calculating the cumulative diff.
% 
% Output:
% 
% - obj      : An nb_ts object with the calculated timeseries stored.
% 
% Examples:
%
% obj = cumdiff(obj);
% obj = cumdiff(obj,true);
%
% See also:
% nb_ts.diff, nb_ts.icumdiff
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        stripNaN = false;
    end

    obj.data = nb_cumdiff(obj.data,stripNaN);
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@cumdiff,{stripNaN});
        
    end

end

function obj = cumegrowth(obj,stripNaN)
% Syntax:
%
% obj = cumegrowth(obj)
% obj = cumegrowth(obj,stripNaN)
%
% Description:
%
% Calculate cumulative growth, using the formula: 
% (x(t)-x(0))/x(0) of all the timeseries of the nb_ts object.
% 
% Input:
% 
% - obj      : An object of class nb_ts
% 
% - stripNaN : Strip nan before calculating the cumulative growth rates.
% 
% Output:
% 
% - obj      : An nb_ts object with the calculated timeseries stored.
% 
% Examples:
%
% obj = cumegrowth(obj);
% obj = cumegrowth(obj,true);
%
% See also:
% nb_ts.egrowth, nb_ts.icumegrowth
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        stripNaN = false;
    end

    obj.data = nb_cumegrowth(obj.data,stripNaN);
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@cumegrowth,{stripNaN});
        
    end

end

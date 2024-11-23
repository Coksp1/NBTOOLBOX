function obj = cumepcn(obj,stripNaN)
% Syntax:
%
% obj = cumepcn(obj)
% obj = cumepcn(obj,stripNaN)
%
% Description:
%
% Calculate percentage cumulative growth, using the formula: 
% 100*((x(t)-x(0))/x(0)) of all the timeseries of the nb_ts object.
% 
% Input:
% 
% - obj      : An object of class nb_ts
% 
% - stripNaN : Strip nan before calculating the percentage cumulative 
%              growth rates.
% 
% Output:
% 
% - obj      : An nb_ts object with the calculated timeseries stored.
% 
% Examples:
%
% obj = cumepcn(obj);
% obj = cumepcn(obj,true);
%
% See also:
% nb_ts.epcn, nb_ts.icumepcn
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        stripNaN = false;
    end

    obj.data = nb_cumepcn(obj.data,stripNaN);
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@cumepcn,{stripNaN});
        
    end

end

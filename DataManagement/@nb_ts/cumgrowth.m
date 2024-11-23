function obj = cumgrowth(obj,stripNaN)
% Syntax:
%
% obj = cumgrowth(obj)
% obj = cumgrowth(obj,stripNaN)
%
% Description:
%
% Calculate cumulative approx growth, using the formula: 
% log(x(t))-log(x(0)) of all the timeseries of the nb_ts object.
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
% obj = cumgrowth(obj);
% obj = cumgrowth(obj,true);
%
% See also:
% nb_ts.growth, nb_ts.icumgrowth
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        stripNaN = false;
    end

    obj.data = nb_cumgrowth(obj.data,stripNaN);
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@cumgrowth,{stripNaN});
        
    end

end

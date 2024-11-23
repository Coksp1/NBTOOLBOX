function obj = setInfinite2NaN(obj)
% Syntax:
%
% obj = setInfinite2NaN(obj)
%
% Description:
%
% Set all elements that are isfinite to nan.
% 
% Input:
% 
% - obj : An object of class nb_ts.
% 
% Output:
% 
% - obj : An object of class nb_ts.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data(~isfinite(obj.data)) = nan;

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@setInfinite2NaN);
        
    end
    
end

function obj = setZero2NaN(obj)
% Syntax:
%
% obj = setZero2NaN(obj)
%
% Description:
%
% Set all elements that are 0 to nan.
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data(obj.data==0) = nan;

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@setZero2NaN);
        
    end
    
end

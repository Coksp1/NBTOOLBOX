function obj = cumsum(obj,varargin)
% Syntax:
%
% obj = cumsum(obj,varargin)
%
% Description:
%
% Cumulativ sum of the series of the object
% 
% Input:
% 
% - obj : An object of class nb_ts, nb_cs or nb_data
% 
% Optional input:
% 
% - Same as for the cumsum function made by MathWorks.
% 
% Output:
% 
% - obj : An nb_ts, nb_cs or nb_data object where the 'data' property of  
%         the object is now the cumulative sum of the old objects 'data' 
%         property.
% 
% Examples:
%
% obj = cumsum(obj,1);
% obj = cumsum(obj,1,'reverse');
% obj = cumsum(obj,'omitnan');
% obj = cumsum(obj,1,'reverse','omitnan');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = cumsum(obj.data,varargin{:});

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@cumsum,varargin);
        
    end
    
end

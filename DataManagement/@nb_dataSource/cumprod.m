function obj = cumprod(obj,varargin)
% Syntax:
%
% obj = cumprod(obj,varargin)
%
% Description:
%
% Cumulativ product of the series of the object
% 
% Input:
% 
% - obj : An object of class nb_ts, nb_cs or nb_data
% 
% Optional input:
% 
% - Same as for the cumprod function made by MathWorks.
% 
% Output:
% 
% - obj : A nb_ts, nb_cs or nb_data object where the 'data' property of 
%         the object is now the cumulative product of the old objects  
%         'data' property.
% 
% Examples:
%
% obj = cumprod(obj,1);
% obj = cumprod(obj,1,'reverse');
% obj = cumprod(obj,'omitnan');
% obj = cumprod(obj,1,'reverse','omitnan');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = cumprod(obj.data,varargin{:});
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@cumprod,varargin);
        
    end

end

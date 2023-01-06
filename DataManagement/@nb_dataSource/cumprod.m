function obj = cumprod(obj,dim)
% Syntax:
%
% obj = cumprod(obj,dim)
%
% Description:
%
% Cumulativ product of the series of the object
% 
% Input:
% 
% - obj : An object of class nb_ts, nb_cs or nb_data
% 
% - dim : In which dimension the cumulativ product should be 
%         calculated. Default is the first dimension.
% 
% Output:
% 
% - obj : A nb_ts, nb_cs or nb_data object where the 'data' property of 
%         the object is now the cumulative product of the old objects  
%         'data' property.
% 
% Examples:
%
% obj = cumprod(obj);
% obj = cumprod(obj,2);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        dim = 1;
    end

    obj.data = cumprod(obj.data,dim);
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@cumprod,{dim});
        
    end

end

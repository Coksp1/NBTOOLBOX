function obj = cumsum(obj,dim)
% Syntax:
%
% obj = cumsum(obj,dim)
%
% Description:
%
% Cumulativ sum of the series of the object
% 
% Input:
% 
% - obj : An object of class nb_ts, nb_cs or nb_data
% 
% - dim : In which dimension the cumulativ sum should be 
%         calculated. Default is the first dimension.
% 
% Output:
% 
% - obj : An nb_ts, nb_cs or nb_data object where the 'data' property of  
%         the object is now the cumulative sum of the old objects 'data' 
%         property.
% 
% Examples:
%
% obj = cumsum(obj);
% obj = cumsum(obj,2);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        dim = 1;
    end

    obj.data = cumsum(obj.data,dim);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@cumsum,{dim});
        
    end
    
end

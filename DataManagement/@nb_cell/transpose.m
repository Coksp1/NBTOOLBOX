function obj = transpose(obj)
% Syntax:
%
% obj = transpose(obj)
%
% Description:
%
% Take the transpose (.') of an nb_cell object. 
% 
% Input:
% 
% - obj : An object of class nb_cell
% 
% Output:
% 
% - obj : An nb_cell object which represents the transposed input 
%         object
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.c    = permute(obj.c,[2,1,3]);
    obj.data = permute(obj.data,[2,1,3]);
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@transpose);
        
    end
    
end

    

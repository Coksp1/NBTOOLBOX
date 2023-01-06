function obj = sum(obj,dim)
% Syntax:
%
% obj = sum(obj,dim)
%
% Description:
%
% Take the sum over a given dimension of an nb_cs object 
% 
% Input:
% 
% - obj : An object of class nb_cs
% 
% - dim : The dimension to take the sum over
% 
% Output:
% 
% - obj : An nb_cs object representing the sum
% 
% Examples:
%
% obj = nb_cs([2,2],'test',{'First'},{'Var1','Var2'});
% obj = sum(obj,2)
% obj = 
% 
%     'Types'    'sum'
%     'First'    [  4]
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        dim = 2;
    end

    switch dim
        
        case 1
            
            obj.data          = sum(obj.data,dim);
            obj.types         = {'sum'};
            
        case 2
            
            obj.data              = sum(obj.data,dim);
            obj.variables         = {'sum'};
            
        case 3
            
            obj.data              = sum(obj.data,dim);
            obj.dataNames         = {'sum'};
            
        otherwise
            
            error([mfilname ':: It is not possible to take the sum over the dimension ' int2str(dim)])
            
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@sum,{dim});
        
    end
    
end

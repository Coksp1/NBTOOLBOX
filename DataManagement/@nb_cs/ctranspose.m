function obj = ctranspose(obj)
% Syntax:
%
% obj = ctranspose(obj)
%
% Description:
%
% Take the transpose (') of an nb_cs object 
% 
% Caution : The former types will be sorted when transposing the 
%           object.
%
% Input:
% 
% - obj : An object of class nb_cs
% 
% Output:
% 
% - obj : An nb_cs object which represents the transposed input 
%         object
% 
% Examples:
% 
% obj = nb_cs([2,2],'test',{'First'},{'Var1','Var2'})
% 
% obj = 
% 
%     'Types'    'Var1'    'Var2'
%     'First'    [   2]    [   2]
% 
% t = obj'
% 
% t = 
% 
%     'Types'    'First'
%     'Var1'     [    2]
%     'Var2'     [    2]
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % We may need to sort the types before assigning them as variables
    var      = obj.types;
    tempData = obj.data';
    
    % Reallocate given that the variables is sorted
    if obj.sorted
        [var,loc] = sort(var);
        tempData  = tempData(:,loc,:);
    end
    obj.types              = obj.variables;
    obj.variables          = var;
    obj.data               = tempData;               
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@ctranspose);
        
    end
    
end

    

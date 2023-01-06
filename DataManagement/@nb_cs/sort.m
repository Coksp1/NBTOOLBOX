function obj = sort(obj,dim,mode,variable)
% Syntax:
%
% obj = sort(obj,dim,mode,variable)
%
% Description:
% 
% Sort the nb_cs object in the given dimension
% 
% Caution : Sorting does not reorder the dataNames, variables or types!
%
% Input:
% 
% - obj      : An object of class nb_cs
% 
% - dim      : The dimension to sort
%  
% - mode     : 'descend' (default)
%              'ascend'
%
% - variable : Give a string with the variable to sort. The rest of the
%              variables will then be reordered accordingly.
%
%              If empty (default), all variables are sorted.
%
%              Caution: Only an option for dim == 1
% 
% Output:
% 
% - obj : An nb_cs object representing the sorted input
% 
% Examples:
%
% obj = nb_cs([1,2;1 1],'test',{'First','Second'},{'Var1','Var2'});
% obj = sort(obj,1,'ascend')
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        variable = '';
        if nargin < 3
            mode = '';
            if nargin < 2
                dim = 2;
            end
        end
    end
    
    if isempty(mode)
        mode = 'descend';
    end

    switch dim
        
        case 1
            
            if isempty(variable)
                obj.data = sort(obj.data,dim,mode);
            else
                ind                = strcmpi(variable,obj.variables);
                dat                = obj.data(:,ind,:);
                [dat,re]           = sort(dat,1,mode);
                obj.data(:,ind,:)  = dat;
                obj.data(:,~ind,:) = obj.data(re,~ind,:);
            end
            
        case {2,3}
            
            obj.data = sort(obj.data,dim,mode);
            
        otherwise
            
            error([mfilname ':: It is not possible to sort over the dimension ' int2str(dim)])
            
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@sort,{dim,mode,variable});
        
    end
    
end

function obj = sort(obj,dim,mode,variable)
% Syntax:
%
% obj = sort(obj,dim,mode,variable)
%
% Description:
% 
% Sort the nb_bd object in the given dimension
% 
% Caution : Sorting does not reorder the dataNames, variables or dates!
%
% Input:
% 
% - obj      : An object of class nb_bd
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
% - obj : An nb_bd object representing the sorted input
% 
% Examples:
%
% obj = nb_bd([1,2;1 1],'test','2012',{'Var1','Var2'});
% obj = sort(obj,1,'ascend')
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
    
    fullData = getFullRep(obj);

    switch dim
        
        case 1
            
            if isempty(variable)
                fullData = sort(fullData,dim,mode);
            else
                ind                = strcmpi(variable,obj.variables);
                dat                = fullData(:,ind,:);
                [dat,re]           = sort(dat,1,mode);
                fullData(:,ind,:)  = dat;
                fullData(:,~ind,:) = fullData(re,~ind,:);
                
            end
            
        case {2,3}
            
            fullData = sort(fullData,dim,mode);
            
            
        otherwise
            
            error([mfilname ':: It is not possible to sort over the dimension ' int2str(dim)])
            
    end
    
    [loc,ind,dataOut] = nb_bd.getLocInd(fullData);
    obj.locations     = loc;
    obj.indicator     = ind;
    obj.data          = dataOut;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@sort,{dim,mode,variable});
        
    end
    
end

function obj = renameMore(obj,type,oldNames,newNames)
% Syntax:
%
% obj = renameMore(obj,type,oldNames,newNames)
%
% Description:
%
% Makes it possible to rename more variables, datasets and types (only 
% nb_cs). 
% 
% Caution : It will resort the variables and the data accordingly
%           when the input type is equal to 'variables', but not when the
%           input is 'datasets'.
%
% Caution : This is the same as looping over nb_dataSource.rename, but 
%           more efficient.
%
% Caution : * syntax is not supported as is the case for 
%           nb_dataSource.rename
% 
% Input:
% 
% - obj      : An object of class nb_dataSource.
% 
% - type     : Either: - 'variables' : To rename a variables
%                      - 'datasets'  : To rename a datasets (The only 
%                                      input that is supported for nb_cell)
%                      - 'types'     : To rename a type (Only nb_cs)
% 
% - oldNames : The old variable/dataset/type names, as a cellstr.
% 
% - newName  : The new variable/dataset/type names, as a cellstr.
% 
% Output:
% 
% - obj : An nb_dataSource object where the variable(s)/dataname(s)/type(s)  
%         of the object given as input is/are renamed.
% 
% Examples:
% 
% obj = nb_cs([22,24;27,28],'Dataset1',{'Exp','Imp'},{'Nor','Swe'})
% obj = renameMore(obj,'dataset',{'Dataset1'},{'tradeBal'});
% obj = renameMore(obj,'variable',{'Nor','Swe'},{'Norway','Sweden'});
% obj = renameMore(obj,'type',{'Exp','Imp'},{'Export','Import'});
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~iscellstr(newNames)
        error([mfilename ':: The ''newNames'' input must be a cellstr.'])
    end

    if ~iscellstr(oldNames)
        error([mfilename ':: The ''oldNames'' input must be a cellstr.'])
    end
    
    if length(newNames) ~= length(oldNames)
        error([mfilename ':: The ''oldNames'' and ''newNames'' input must be of same size.'])
    end
    
    test = unique(newNames);
    if length(newNames) ~= length(test)
        error([mfilename ':: The ''newNames'' input must consist of unique names.'])
    end

    switch lower(type)

        case {'variable','variables'}

            [~,found] = ismember(oldNames,obj.variables);
            if any(~found)
                error([mfilename ':: The variable(s) ' toString(oldNames(~found)) ' is not found to be in the object.'])
            else
                obj.variables(found) = newNames;
            end
            
            % Resort the variables and the data accordingly
            if obj.sorted
                vars          = obj.variables;
                obj.variables = sort(obj.variables);
                locations     = nb_ts.locateVariables(obj.variables,vars);
                obj.data      = obj.data(:,locations,:); 
            end  

        case {'dataset','datasets'}

            [~,found] = ismember(oldNames,obj.dataNames);
            if any(~found)
                error([mfilename ':: The dataset(s) ' toString(oldNames(~found)) ' is not found to be in the object.'])
            else
                obj.dataNames(found) = newNames;
            end
            
         case {'type','types'}

            [~,found] = ismember(oldNames,obj.types);
            if any(~found)
                error([mfilename ':: The type(s) ' toString(oldNames(~found)) ' is not found to be in the object.'])
            else
                obj.types(found) = newNames;
            end
            
        otherwise

            error([mfilename ':: You cannot rename a ' type '.'])
    end
    
    if obj.isUpdateable()
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@renameMore,{type,oldNames,newNames});
    end

end

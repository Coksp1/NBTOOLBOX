function obj = rename(obj,type,oldName,newName)
% Syntax:
%
% obj = rename(obj,type,oldName,newName)
%
% Description:
%
% Makes it possible to rename variables and datasets. For objects of 
% class nb_cs types is also possible to rename.
% 
% Caution : It will resort the variables and the data accordingly
% when the input type is equal to 'variable', but not when the
% input is 'dataset' or 'types'.
% 
% Input:
% 
% - obj     : An object of class nb_dataSource
% 
% - type    : Either: - 'variable' : To rename a variable(s)
%                     - 'dataset'  : To rename a dataset(s) (The only 
%                                    input that is supported for nb_cell)
%                     - 'types'    : To rename a type(s) (only nb_cs)
% 
% - oldName : Case 1;
% 
%             > The old variable/dataset/type name, as a string
% 
%             Case 2:
% 
%             > The string which should be replaced in all the
%               variable names of the database. And reorder things
%               afterwards. This input must end with a *.
% 
% - newName : Case 1;
% 
%             > The new variable/dataset/type name, as a string
% 
%             Case 2;
% 
%             > The string which should replace the old string part
%               given by the input 'oldName'. 
% 
% Output:
% 
% - obj : An nb_dataSource object with the renamed variable(s), type(s) 
%         or dataset(s).
% 
% Examples:
%
% obj = nb_cs([2,2],'test',{'First'},{'Var1','Var2'});
% obj = obj.rename('variable','Var1','Var3');
% obj = obj.rename('variable','Var*','N_Var');
% obj = rename(obj,'variable',{'Var1','Var2'},{'VAR1','VAR2'});
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if iscellstr(oldName)
        
        if iscellstr(newName)
            if length(oldName) ~= length(newName)
                error([mfilename ':: The oldName and newName inputs must have same length.'])
            end
        else
            error([mfilename ':: The newName input must be a cellstr if oldName is a cellstr.'])
        end
        for ii = 1:length(oldName)
            obj = rename(obj,type,oldName{ii},newName{ii});
        end
        return
        
    end

    if ~ischar(newName)
        error([mfilename ':: The newName input must be a string if the oldName input is a string.'])
    end

    if ~ischar(oldName)
        error([mfilename ':: The oldName input must be a string or a cellstr.'])
    end

    switch lower(type)

        case {'variable','variables'}

            if isa(obj,'nb_cell')
                error([mfilename ':: Unsupported type ''' type ''' for an object of class ' class(obj) '.'])
            end
            
            starInd = strfind(oldName,'*');
            if isempty(starInd)

                found = find(strcmp(oldName,obj.variables));
                if isempty(found)
                    error([mfilename ':: The variable ''' oldName ''' is not found to be in the object.'])
                else
                    obj.variables{found} = newName;
                end

                % Resort the variables and the data accordingly
                if obj.sorted
                    vars          = obj.variables;
                    obj.variables = sort(obj.variables);
                    locations     = nb_ts.locateVariables(obj.variables,vars);
                    obj.data      = obj.data(:,locations,:);  
                end

            else
                
                starInd = starInd(1);
                if starInd == 1

                    obj.variables = strrep(obj.variables,oldName(2:end),newName);
                    if obj.sorted
                        % Resort the variables and the data accordingly
                        vars          = obj.variables;
                        obj.variables = sort(obj.variables);
                        locations     = nb_ts.locateVariables(obj.variables,vars);
                        obj.data      = obj.data(:,locations,:);  
                    end
                    
                else
                    
                    obj.variables = strrep(obj.variables,oldName(1:starInd - 1),newName);
                    if obj.sorted
                        % Resort the variables and the data accordingly
                        vars          = obj.variables;
                        obj.variables = sort(obj.variables);
                        locations     = nb_ts.locateVariables(obj.variables,vars);
                        obj.data      = obj.data(:,locations,:);  
                    end
                    
                end

            end

        case {'type','types'}
            
            if ~isa(obj,'nb_cs')
                error([mfilename ':: Unsupported type ''' type ''' for an object of class ' class(obj) '.'])
            end
            starInd = strfind(oldName,'*');
            if isempty(starInd)
                found = find(strcmp(oldName,obj.types));
                if isempty(found)
                    error([mfilename ':: The type ''' oldName ''' is not found to be in the object.'])
                else
                    obj.types{found} = newName;
                end
            else
                starInd = starInd(1);
                if starInd == 1
                    obj.types = strrep(obj.types,oldName(2:end),newName);
                else
                    obj.types = strrep(obj.types,oldName(1:starInd - 1),newName);
                end
            end    

        case {'dataset','datasets','page','pages'}

            starInd = strfind(oldName,'*');
            if isempty(starInd)
                found = find(strcmp(oldName,obj.dataNames));
                if isempty(found)
                    error([mfilename ':: The dataset ''' oldName ''' is not found to be in the object.'])
                else
                    obj.dataNames{found} = newName;
                end
            else
                starInd = starInd(1);
                if starInd == 1
                    obj.dataNames = strrep(obj.dataNames,oldName(2:end),newName);
                else
                    obj.dataNames = strrep(obj.dataNames,oldName(1:starInd - 1),newName);
                end
            end

        otherwise
            error([mfilename ':: You cannot rename a ' type '.'])
    end
    
    if obj.isUpdateable()
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@rename,{type,oldName,newName});
    end

end

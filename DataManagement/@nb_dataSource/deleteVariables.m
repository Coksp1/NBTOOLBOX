function obj = deleteVariables(obj,deletedVar)
% Syntax:
%
% obj = deleteVariables(obj,deletedVar)
%
% Description:
% 
% Delete variables from the current nb_ts, nb_data or nb_cs object (letter  
% size has somthing to say)
%
% If some of the variables you specify in deletedVar does not exist 
% in the obj, this will not have anything to say for the obj. (The 
% variables cannot be deleted, because the variables do not exist.)
% 
% Input:
% 
% - obj        : An object of class nb_ts, nb_data or nb_cs
% 
% - deletedVar : Must be a char or a cellstr
% 
%     Delete all the variable names, given in the char array 
%     or cellstr array deletedVar, of current the object.
% 
%     NB! If deletedVar is just one string and include a * as the 
%         last letter, this function will delete all the variable 
%         names, from the object, that start with the letters which 
%         is in front of the * in the string. 
% 
%         i.e. obj = deleteVariables(obj,'DPQ*');
% 
%         Deletes all the variables in the obj which has variable 
%         names starting with 'DPQ'.
% 
%         If deletedVar is just one string and include a * as the 
%         first letter, this function will delete all the variable 
%         names, from the object, that include the letters which 
%         follows in the string.
% 
%         i.e. obj = deleteVariables(obj, '*shift');
% 
%         Deletes all the variables in the obj which has variable 
%         names which include 'shift'.
% 
% Output: 
%
% - obj : A nb_ts, nb_data or nb_cs object with the variables specified in 
%         deletedVar deleted.
% 
% Examples:
%
% obj = nb_cs([2,2],'test',{'First'},{'Var1','Var2'});
% obj = deleteVariables(obj, {'Var1','Var2'});
% obj = deleteVariables(obj, char('Var1','Var2'));
% obj = deleteVariables(obj, obj.variables);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(obj,'nb_cell')
        error([mfilename ':: nb_cell object does not have variables.'])
    end

    if ~ischar(deletedVar) && ~iscellstr(deletedVar)
        error([mfilename ':: The second argument (including the object itself) should be a char, char array or a cellstr'])
    end

    if isempty(obj.variables)
        warning([mfilename,':: The object dosen''t contain any variables, no variables to be deleted']) 
    end

    if ischar(deletedVar) && (size(deletedVar, 1) == 1) && nb_contains(deletedVar,'*')

        if strcmp('*',deletedVar(1,1))

            % Delete all variables including the string 
            % 'deletedVar'
            varIndex = zeros(size(obj.variables));
            for j = 1:size(obj.variables,2)

                try
                    found = strfind(obj.variables{j}, strtrim(deletedVar(1,2:end)));

                    if ~isempty(found)
                        varIndex(j) = 1;
                    end
                catch err

                    if strcmp(err.identifier,'MATLAB:index_assign_element_count_mismatch')
                        % Do nothing
                    else
                        rethrow(err)
                    end
                end
            end
        else

            % Delete all variables starting with the string 
            % 'deletedVar'
            varIndex = zeros(size(obj.variables));
            len      = length(deletedVar) - 1;
            for j = 1:size(obj.variables,2) 
                try 
                    varIndex(j) = strcmp(obj.variables{j}(1,1:len), strtrim(deletedVar(1,1:end-1)));
                catch err

                    if strcmp(err.identifier,'MATLAB:badsubscript')
                        % Do nothing. (the obj.variables{j} 
                        % is to short to possibly be starting 
                        % with the string 'deletedVar')
                    else
                        rethrow(err)
                    end
                end
            end
        end
    else
        % Here we delete all variables given in the array 
        % 'deletedVar' (can be of size 1)

        deletedVar = cellstr(deletedVar);
        varIndex   = zeros(size(obj.variables));
        for j = 1:length(deletedVar)

            varIndex = varIndex + strcmp(deletedVar{j}, obj.variables);

        end

    end

    % Delete the found variables in the dataset 
    varlocs = find(~varIndex);
    if isempty(varlocs)

        % All the variables is being deleted
        obj = empty(obj);

    else
        obj.variables = obj.variables(varlocs);
        obj.data      = obj.data(:,varlocs,:);
    end

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@deleteVariables,{deletedVar});
        
    end
    
end

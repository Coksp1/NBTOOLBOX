function obj = keepVariables(obj,keptVar)
% Syntax:
%
% obj = keepVariables(obj,keptVar)
%
% Description:
% 
% Keep variables from the current nb_data object (letter size 
% has something to say)
% 
% If some of the variables you specify in keptVar does not exist 
% in the object, this will not have anything to say for the object. 
% (The variables cannot be kept, because the variables do not 
% exist.)
% 
% Input:
% 
% - obj        : An object of class nb_data
% 
% - keptVar    : Must be a char or a cellstr
% 
%     Keeps all the variable names, given in the char array 
%     or cellstr array keptVar, of current the nb_ts object.
% 
%     NB! If keptVar is just one string and include a * as the last 
%         letter, this function will keep all the variable names, 
%         from the DB, that start with the letters which is in 
%         front of the * in the string. 
% 
%         i.e. obj = keepVariables(obj,'DPQ*');
% 
%         Keep all the variables in the obj which has variable 
%         names starting with 'DPQ'.
% 
% 
%         If keptVar is just one string and include a * as the 
%         first letter, this function will keep all the variable 
%         names, from the DB, that include the letters which 
%         follows in the string.
% 
%         i.e. obj = keepVariables(obj, '*shift');
% 
%         Keeps all the variables in the obj which has variable 
%         names which include 'shift'.
% 
% Output: 
%
% - obj : An nb_data object with the variables specified in input
%         'keptVar' kept, all the others are deleted.
% 
% Examples:
%
% obj = keepVariables(obj, {'Var1','Var2'});
% obj = keepVariables(obj, char('Var1','Var2'));
% obj = keepVariables(obj, DB.variables);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~ischar(keptVar) && ~iscellstr(keptVar)
        error([mfilename ':: The second argument (including the object itself) should be a char, char array or a cellstr'])
    end

    if isempty(obj.variables)
        warning('nb_data:keepVariables:empty',[mfilename,':: The object dosen''t contain any variables, no variables to be kept']) 
    end

    if ischar(keptVar) && (size(keptVar, 1) == 1) && ~isempty(strfind(keptVar,'*'))

        if strcmp('*',keptVar(1,1))

            % Keep all variables including the string 
            % 'keptVar'
            varIndex = zeros(size(obj.variables));
            for j = 1:size(obj.variables,2)

                try
                    found = strfind(obj.variables{j}, strtrim(keptVar(1,2:end)));

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

            % Keep all variables starting with the string 
            % 'keptVar'
            varIndex = zeros(size(obj.variables));
            len      = length(keptVar) - 1;
            for j = 1:size(obj.variables,2) 
                try 
                    varIndex(j) = strcmp(obj.variables{j}(1,1:len), strtrim(keptVar(1,1:end-1)));
                catch err

                    if strcmp(err.identifier,'MATLAB:badsubscript')
                        % Do nothing. (the obj.variables{j} 
                        % is to short to possibly be starting 
                        % with the string 'keptVar')
                    else
                        rethrow(err)
                    end

                end
            end

        end

    else
        % Here we keep all the variables given in the array 
        % 'keptVar' (can be of size 1)

        keptVar  = cellstr(keptVar);
        varIndex = zeros(size(obj.variables));
        for j = 1:length(keptVar)
            varIndex = varIndex + strcmp(keptVar{j}, obj.variables);
        end

    end

    % Keep the found variables in the dataset 
    varlocs = find(varIndex);
    if isempty(varlocs)

        % No variables to keep
        obj = obj.empty();

    else
        nvar                  = size(varlocs,2);
        obj.variables         = obj.variables(varlocs);
        obj.data              = obj.data(:,varlocs,:);
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@keepVariables,{keptVar});
        
    end

end

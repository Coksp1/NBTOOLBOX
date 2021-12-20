function variableData = getVariable(obj,variableName,typesOfVariable,pages)
% Syntax:
%
% variableData = getVariable(obj,variableName,...
%                             typesOfVariable,pages)
%
% Description:
%
% Get the data of a variable of an nb_cs object
% 
% Input:
% 
% - obj             : An object of class nb_cs
% 
% - variableName    : The variable you want the data of. Must be given
%                     as a string (name of variable) or a cellstr.
% 
% - typesOfVariable : The wanted types, given as a cellstr.
% 
% - pages           : Pages of the return data of the given variable. 
%                     As a double or logical array, e.g. [1:2] or 
%                     [1,3,5].
% 
% Output:
% 
% - variableData : The data of the variable you have given as a  
%                  double. Return [] if not found.  
% 
% Examples:
% 
% obj = nb_cs([2,2; 2,2],'test',{'Type1','Type2'},{'Var1','Var2'});
% variableData = getVariable(obj,'Var1');
% variableData = getVariable(obj,'Var1',{'Type1'});
% variableData = getVariable(obj,'Var1',{'Type1'},1);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        pages = [];
        if nargin < 3
            typesOfVariable = {};
        end
    end

    if isempty(variableName)
        variableData = [];
        return
    end
    
    if isempty(obj)

        variableData = [];

    else
        
        % Get variable index
        if iscellstr(variableName)
        
            [ind,varInd] = ismember(variableName, obj.variables);
            if ~all(ind)
                error([mfilename ':: Some of the provided variable names are not found.'])
            end
            
        else
            
            varInd = strcmp(variableName, obj.variables);
            if sum(varInd)==0
                error([mfilename ':: Variable ''' variableName ''' not found.'])
            end

        end

        % Get the index of the types to keep
        if ~isempty(typesOfVariable)

            typesOfVariable = cellstr(typesOfVariable);

            typesInd = zeros(1,max(size(obj.types)));
            for ii = 1:max(size(typesOfVariable))
                var_id = strcmp(typesOfVariable{ii},obj.types);
                typesInd = typesInd + var_id;
                if sum(var_id)==0
                    warning('nb_cs:window:TypeNotFound',[mfilename ':: Type ''' typesOfVariable{ii} ''' not found.']) 
                end
            end

            typesInd = logical(typesInd);

        else

            typesInd = 1:obj.numberOfTypes; % To ensure that we keep all types

        end

        % Default is all pages (datasets)
        if isempty(pages)
           pages = 1:obj.numberOfDatasets;
        else
            m = max(pages);
            if m > obj.numberOfDatasets
                error([mfilename ':: The object consist only of ' int2str(obj.numberOfDatasets) ' datasets. You are trying to reach the dataset ' int2str(m) ', which is not possible.'])
            end   
        end

        variableData = obj.data(typesInd,varInd,pages);
    end

end

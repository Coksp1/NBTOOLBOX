function variableData = getVariable(obj,variableName,startObs,endObs,pages)
% Syntax:
%
% variableData = getVariable(obj,variableName,startObs,endObs,pages)
%
% Description:
%
% Get the data of a variable, as a double
% 
% Input:
% 
% - obj          : An object of class nb_data
% 
% - variableName : The variable you want the data of. Must be given
%                  as a string (name of variable) or a cellstr.
% 
% - startObs     : Start obs of the return data of the given
%                  variable. As an integer
% 
% - endObs       : End obs of the return data of the given
%                  variable. As an integer
% 
% - pages        : Pages of the return data of the given variable. 
%                  As a double or logical array, e.e. [1:2] or 
%                  [1,3,5].
% 
% Output:
% 
% - variableData : The data of the variable you have given. Return 
%                  [] if not found.
% 
% Examples:
% 
% variableData = getVariable(obj,'Var1');
% variableData = getVariable(obj,'Var1',1);
% variableData = getVariable(obj,'Var1',1,2);
% variableData = getVariable(obj,'Var1',1,2,[1:3]);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        pages = [];
        if nargin < 4
            endObs = [];
            if nargin < 3
                startObs = [];
            end
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
        
        % Get start date index
        if isempty(startObs)
            startInd = 1;
        else
            
            startInd = startObs - obj.startObs + 1;
            if startInd < 1 || startInd > obj.numberOfObservations

                error([mfilename ':: the start obs of the wanted data (''' int2str(startObs) ''') starts before the start obs of the object '...
                                 '(''' int2str(obj.startObs) ''') or after the end date of the object (' int2str(obj.endObs) ')'])

            end
        end

        % Get end date index
        if isempty(endObs)
            endInd = obj.numberOfObservations;
        else
            
            endInd = endObs - obj.startObs + 1;
            if endInd < 1 || endInd > obj.numberOfObservations

                error([mfilename ':: the start date of the wanted data (''' int2str(endObs) ''') starts before the start date of the object '...
                                 '(''' int2str(obj.startObs) ''') or after the end date of the object (' int2str(obj.endObs) ')'])

            end
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

        variableData = obj.data(startInd:endInd,varInd,pages);
        
    end

end

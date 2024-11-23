function variableData = getVariable(obj,variableName,startDate,endDate,pages)
% Syntax:
%
% variableData = getVariable(obj,variableName,startDate,...
%                            endDate,pages)
%
% Description:
%
% Get the data of a variable, as a double
% 
% Input:
% 
% - obj          : An object of class nb_ts
% 
% - variableName : The variable you want the data of. Must be given
%                  as a string (name of variable) or a cellstr.
% 
% - startDate    : Start date of the return data of the given
%                  variable. As a string or an object which is of a
%                  subclass of nb_date
% 
% - endDate      : End date of the return data of the given
%                  variable. As a string or an object which is of a
%                  subclass of nb_date
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
% variableData = getVariable(obj,'Var1','2012Q1');
% variableData = getVariable(obj,'Var1','2012Q1','2012Q4');
% variableData = getVariable(obj,'Var1','2012Q1','2012Q4',[1:3]);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 5
        pages = [];
        if nargin < 4
            endDate = '';
            if nargin < 3
                startDate = '';
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
        if isempty(startDate)
            startInd = 1;
        else
            startDate = nb_date.toDate(startDate, obj.frequency);
            startInd  = startDate - obj.startDate + 1;

            if startInd < 1 || startInd > obj.numberOfObservations

                error([mfilename ':: the start date of the wanted data (''' startDate.toString ''') starts before the start date of the object '...
                                 '(''' obj.startDate.toString ''') or after the end date of the object (' obj.endDate.toString ')'])

            end
        end

        % Get end date index
        if isempty(endDate)
            endInd = obj.numberOfObservations;
        else
            endDate = nb_date.toDate(endDate, obj.frequency);
            endInd = endDate - obj.startDate + 1;

            if endInd < 1 || endInd > obj.numberOfObservations

                error([mfilename ':: the end date of the wanted data (''' endDate.toString ''') starts before the start date of the object '...
                                 '(''' obj.startDate.toString ''') or after the end date of the object (' obj.endDate.toString ')'])

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

function obj = stripButLast(obj,numPeriods,variables)
% Syntax: 
%
% obj = stripButLast(obj,numPeriods,variables)
%
% Description:
%
% Sets all values of the given variables of a nb_data object, except a   
% given amount of observations at the end, to nan.
% 
% Input: 
%
% - obj        : A nb_data object
% 
% - numPeriods : The amount of observations to be left as-is in the
%                object. If the input is given to 2, the returned  
%                object will have all it's observations set to nan 
%                except the last two observations.
%
% - variables  : A cellstring with the variables to perform the  
%                method on. Can be empty, in which case the method  
%                will be performed on all variables in the object.
% 
% Output: 
%
% - obj        : A nb_data object
% 
% Examples: 
%
% strippedObj = stripButLast(obj,5,{'Var1','Var2'})
% strippedObj = stripButLast(obj,'5')
%
% Written by Eyo Herstad

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        variables = []; 
    end

    % Check input
    %---------------------------------------
    if isempty(obj)
        
        warning('nb_data:EmptyObject',[mfilename ':: The object you are trying to strip observatiosns of is empty. Returning an empty object.']);
        return
        
    end
  
    if isnumeric(numPeriods)
        if numPeriods < 0 || numPeriods > obj.numberOfObservations
            error([mfilename ':: The number of periods to be kept cannot be below zero, or be higher than the number of observations of the data.']);
            
        end
    else
        numPeriods = str2double(numPeriods);
        if isnan(numPeriods)
            error([mfilename ':: invalid numPeriods input, must be either a double, or a string with a number (i.e. ''8'').']);
        else
            if numPeriods < 0 || numPeriods > obj.numberOfObservations
            error([mfilename ':: The number of periods to be kept cannot be below zero, or be higher than the number of observations of the data.']);
            end
        end
    end
    
    ind = zeros(obj.numberOfObservations,1);
    ind(1:obj.numberOfObservations-numPeriods) = 1;
    ind = logical(ind);
    
    if ~isempty(variables)

        variables = cellstr(variables);

        variablesInd = zeros(1,max(size(obj.variables)));
        for ii = 1:max(size(variables))
            var_id       = strcmp(variables{ii},obj.variables);
            variablesInd = variablesInd + var_id;
            if sum(var_id)==0
                warning('nb_data:window:VariableNotFound',[mfilename ':: Variable ''' variables{ii} ''' not found.']) 
            end
        end

        variablesInd = logical(variablesInd);

    else

        variablesInd = true(1,size(obj.variables,2)); % To ensure that we keep all variables

    end    
    
    % Perform the strip
    obj.data(ind,variablesInd,:) = nan;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object. (Cannot give pages, because the links are already
        % removed)
        obj = obj.addOperation(@stripButLast,{numPeriods,variables});
        
    end
    
end


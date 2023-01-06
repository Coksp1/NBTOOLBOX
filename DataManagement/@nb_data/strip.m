function obj = strip(obj,startObs,endObs,variables)
% Syntax: 
%
% obj = strip(obj,startObs,endObs,variables)
%
% Description:
%
% Sets all values of the given variables of a nb_data object,  between two 
% given observations, to nan.
% 
% Input: 
%
% - obj       : A nb_data object
% 
% - startObs  : The starting point of the strip, must be either an  
%               nb_date object or a valid input to the toDate  
%               method of the nb_date class
%
% - endObs    : The starting point of the strip, must be either an  
%               nb_date object or a valid input to the toDate  
%               method of the nb_date class
%
% - variables : A cellstring with the variables to perform the 
%               method on. Can be empty, in which case the method  
%               will be performed on all variables in the object.
% 
% Output: 
%
% - obj       : A nb_data object
% 
% Examples: 
%
% strippedObj = strip(obj,'2011Q1','2012Q3',{'Var1','Var2'})
% strippedObj = strip(obj,'2011Q1','2012Q3')
%
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        variables = {}; 
    end

    % Check input
    %---------------------------------------
    if isempty(obj)
        
        warning('nb_data:EmptyObject',[mfilename ':: The object you are trying to strip observatiosns of is empty. Returning a empty object.']);
        return
        
    end
  
    % Check obs

    if ~isempty(startObs)
        
        startInd = (startObs - obj.startObs) + 1;
        if startInd < 1 
            error([mfilename ':: beginning of window (''' int2str(startObs) ''') starts before the start obs (''' int2str(obj.startDate) ''') '...
                'or starts after the end obs (''' int2str(obj.endDate) ''') of the data '])
        end
        
    else
        startInd = 1;
        startObs = obj.startObs;
    end
    
    if ~isempty(endObs)
        
        endInd = (endObs - obj.startObs) + 1;
        if endInd > obj.numberOfObservations
            error([mfilename ':: end of window (''' int2str(endObs) ''') ends after the end obs (''' int2str(obj.endDate) ''') or '...
                'ends before the start obs (''' int2str(obj.startDate) ''') of the data '])  
        end
        
    else
        endInd = obj.numberOfObservations;
        endObs = obj.endObs;
    end

    % Remove all other variables
    if ~isempty(variables)

        variables = cellstr(variables);

        variablesInd = zeros(1,max(size(obj.variables)));
        for ii = 1:max(size(variables))
            var_id = strcmp(variables{ii},obj.variables);
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
    obj.data(startInd:endInd,variablesInd,:) = nan;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object. (Cannot give pages, because the links are already
        % removed)
        obj = obj.addOperation(@strip,{startObs,endObs,variables});
        
    end
    
end


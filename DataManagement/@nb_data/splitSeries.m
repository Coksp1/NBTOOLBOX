function obj = splitSeries(obj,variable,obs,postfix,overlapping)
% Syntax:
%
% obj = splitSeries(obj,variable,obs,postfix,overlapping)
%
% Description:
%
% Split a series into two variables at a given observation. 
% 
% Input:
% 
% - obj         : An object of class nb_data
%
% - variable    : The variable(s) to split. Either a string or a 
%                 cellstr.
%
% - obs         : The observation to split the series. As an integer.
%
% - postfix     : A string with the postfix of the new variable(s).
% 
% - overlapping : Indicate if you want the splitted series to be
%                 overlapping or not. As a logical. Default is 
%                 true.
%
% Output:
% 
% - obj      : An object of class nb_data with the splitted series
%              added.
%
% See also:
% nb_ts, nb_ts.splitSample
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        overlapping = true;
        if nargin < 4
            postfix = '_split';
        end
    end

    if ischar(variable)
        variable = cellstr(variable);
    end
    if size(variable,1) > 1
        variable = variable';
    end
    
    if isempty(postfix)
        error([mfilename ':: Postfix cannot be empty.'])
    end
    if ~ischar(postfix)
        error([mfilename ':: Postfix must be a string.'])
    end
    
    if ~nb_iswholenumber(obs)
        error([mfilename ':: obs input must be an integer'])
    end
    
    [ind,vInd] = ismember(variable,obj.variables);
    if any(~ind)
        error([mfilename ':: The variables ' nb_cellstr2String(variable(~ind)) ' are not (a) variable(s) the dataset.'])
    end
    vData    = obj.data(:,vInd,:);
    nVar     = strcat(variable,postfix(1,:));
    indFound = ismember(nVar,obj.variables);
    if any(indFound)
        error([mfilename ':: The added postfix will result in (a) variable(s) that already exist in the dataset;' nb_cellstr2String(nVar(indFound))])
    end
    
    % Split data into two variables
    sInd = obs - obj.startObs+ 1;
    if sInd < 1
        sInd = 1;
    end
    if overlapping
        o = 1; 
    else
        o = 0;
    end
    
    obj.data(sInd+o:end,vInd,:) = nan;
    newData                     = [nan(sInd-1,length(nVar),obj.numberOfDatasets);vData(sInd:end,:,:)];
    
    % Add the new variable to the object
    if obj.sorted
        oVar               = obj.variables;
        obj.variables      = sort([obj.variables nVar]);
        [~,nInd]           = ismember(nVar,obj.variables);
        [~,oInd]           = ismember(oVar,obj.variables);
        dataTemp           = nan(obj.numberOfObservations,obj.numberOfVariables,obj.numberOfDatasets);
        dataTemp(:,nInd,:) = newData;
        dataTemp(:,oInd,:) = obj.data;
        obj.data           = dataTemp;
    else
        obj.variables = [obj.variables nVar];
        obj.data      = [obj.data,newData];
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@splitSeries,{variable,obs,postfix,overlapping});
        
    end
    
end

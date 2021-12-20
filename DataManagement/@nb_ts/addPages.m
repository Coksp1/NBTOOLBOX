function obj = addPages(obj,DB,varargin)
% Syntax:
%
% obj = addPages(obj,DB,varargin)
% 
% Description:
%
% Add all pages from different nb_ts objects.
% 
% Caution : This method will break the link to the data source of 
%           updateable objects!
%
% Input:
% 
% - obj      : An object of class nb_ts
% 
% - DB       : An object of class nb_ts
%
% - varargin : Optional number of objects of class nb_ts
% 
% Output:
% 
% - obj      : The object itself with added datasets from the 
%              objects given by varargin.
% 
%              Be aware: If the added datsets does not contain the 
%              same variables or dates, the data of the nb_ts 
%              object with the tightest window will be expanded 
%              automatically to include all the same dates and 
%              variables. (the added data will be set as nan)
% 
% Examples:
%
% obj = obj.addPages(DB);
% obj = obj.addPages(DB1,DB2,DB3);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(obj)
        obj = DB;
        if obj.isUpdateable()
            % This method break the link to the data
            obj.links      = struct([]);
            obj.updateable = 0;
        end
        return;
    elseif isempty(DB)
        if obj.isUpdateable()
            % This method break the link to the data
            obj.links      = struct([]);
            obj.updateable = 0;
        end
        return;
    end

    if ~isa(DB,'nb_ts') || ~isa(obj,'nb_ts')
        error([mfilename ':: The added objects must be nb_ts objects.'])
    end

    if obj.frequency ~= DB.frequency
        error([mfilename ':: You cannot use the method addPages for nb_ts objects with different frequencies.'])
    end
    
    % Merge local variables
    try
        obj.localVariables = nb_structcat(obj.localVariables,DB.localVariables);
    catch Err
        error([mfilename ':: Could not merge the local variables from the nb_ts objects. ' Err.message])
    end
    
    % Add the pages
    for ii = 1:DB.numberOfDatasets

        if ~isempty(find(strcmp(DB.dataNames{ii},obj.dataNames),1))
            exp = regexp(DB.dataNames{ii},'Database[0-9]+','match');
            if isempty(exp)
                obj = obj.addDataset(DB.data(:,:,ii), [DB.dataNames{ii} '(2)'], DB.startDate, DB.variables);
            else
                obj = obj.addDataset(DB.data(:,:,ii), '', DB.startDate.toString, DB.variables);
            end
        else
            obj = obj.addDataset(DB.data(:,:,ii), DB.dataNames{ii}, DB.startDate.toString, DB.variables);
        end

    end
    
    if obj.isUpdateable()
        % This method break the link to the data
        obj.links      = struct([]);
        obj.updateable = 0;
    end
    
    if ~isempty(varargin)
        obj = addPages(obj,varargin{:});
    end

end

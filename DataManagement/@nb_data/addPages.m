function obj = addPages(obj,DB,varargin)
% Syntax:
%
% obj = addPages(obj,DB,varargin)
% 
% Description:
%
% Add all pages from different nb_data objects.
% 
% Caution : This method will break the link to the data source of 
%           updateable objects!
%
% Input:
% 
% - obj      : An object of class nb_data
% 
% - DB       : An object of class nb_data
%
% - varargin : Optional number of objects of class nb_data
% 
% Output:
% 
% - obj      : The object itself with added datasets from the 
%              objects given by varargin.
% 
%              Be aware: If the added datsets does not contain the 
%              same variables or observations, the data of the nb_data
%              object with the tightest window will be expanded 
%              automatically to include all the same observations and 
%              variables. (the added data will be set as nan)
% 
% Examples:
%
% obj = obj.addPages(DB);
% obj = obj.addPages(DB1,DB2,DB3);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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

    if ~isa(DB,'nb_data') || ~isa(obj,'nb_data')
        error([mfilename ':: The added objects must be nb_data objects.'])
    end
    
    for ii = 1:DB.numberOfDatasets

        if ~isempty(find(strcmp(DB.dataNames{ii},obj.dataNames),1))

            expr = regexp(DB.dataNames{ii},'Database[0-9]+','match');

            if isempty(expr)
                obj = obj.addDataset(DB.data(:,:,ii), [DB.dataNames{ii} '(2)'], DB.startObs, DB.variables);
            else
                obj = obj.addDataset(DB.data(:,:,ii), '', DB.startObs, DB.variables);
            end
        else
            obj = obj.addDataset(DB.data(:,:,ii), DB.dataNames{ii}, DB.startObs, DB.variables);
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

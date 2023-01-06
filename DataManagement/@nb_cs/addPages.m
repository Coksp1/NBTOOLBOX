function obj = addPages(obj,DB,varargin)
% Syntax:
%
% obj = addPages(obj,DB)
%
% Description:
%
% Add all pages from a different nb_cs object with the current
% one
% 
% Caution : This method will break the link to the data source of 
%           updateable objects!
%
% Input:
% 
% - obj      : An object of class nb_cs
% 
% - DB       : An object of class nb_cs
%
% - varargin : Optional number of objects of class nb_cs
% 
% Output:
% 
% - obj : An object of class nb_cs with all the datasets from the 
%         objects obj and varargin.
%
%         Be aware: If the added datsets does not contain the same
%         variables or types, the data of the nb_cs object with
%         the tightest window will be expanded automaticly to 
%         include all the same types and variables. (the added data
%         will be set as nan)
% 
% Examples:
%
% obj = addPages(obj,DB);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isa(DB,'nb_cs') || ~isa(obj,'nb_cs')
        error([mfilename ':: The added pages must both be nb_cs objects.'])
    end
     
    for ii = 1:DB.numberOfDatasets

        if ~isempty(find(strcmp(DB.dataNames{ii},obj.dataNames),1))
            exp = regexp(DB.dataNames{ii},'Database[0-9]+','match');
            if isempty(exp)
                obj = obj.addDataset(DB.data(:,:,ii), [DB.dataNames{ii} '(2)'], DB.types, DB.variables);
            else
                obj = obj.addDataset(DB.data(:,:,ii), '', DB.types, DB.variables);
            end
        else
            obj = obj.addDataset(DB.data(:,:,ii), DB.dataNames{ii}, DB.types, DB.variables);
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

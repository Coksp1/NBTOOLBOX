function obj = addPages(obj,DB,varargin)
% Syntax:
%
% obj = addPages(obj,DB)
%
% Description:
%
% Add all pages from a different nb_bd object with the current
% one
% 
% Caution : This method will break the link to the data source of 
%           updateable objects!
%
% Input:
% 
% - obj      : An object of class nb_bd
% 
% - DB       : An object of class nb_bd
%
% - varargin : Optional number of objects of class nb_bd
% 
% Output:
% 
% - obj : An object of class nb_bd with all the datasets from the 
%         objects obj and varargin.
%
%         Be aware: If the added datsets does not contain the same
%         variables or dates, the data of the nb_bd object with
%         the tightest window will be expanded automatically to 
%         include all the same dates and variables. (The added data
%         will be set as nan when expanded to full representation.)
% 
% Examples:
%
% obj = addPages(obj,DB);
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isa(DB,'nb_bd') || ~isa(obj,'nb_bd')
        error([mfilename ':: The added pages must both be nb_bd objects.'])
    end
    
    numObsPerPage = nan(1,DB.numberOfDatasets);
    for ii = 1:DB.numberOfDatasets
        ind = (ii - 1)*DB.numberOfVariables+1:ii*DB.numberOfVariables;
        if DB.indicator
            numObsPerPage(ii) = full(sum(sum(DB.locations(:,ind))));
        else
            numObsPerPage(ii) = full(sum(sum(~DB.locations(:,ind))));
        end
    end
    
    s = 0;
    for ii = 1:DB.numberOfDatasets  
        dataset = DB.data(s+1:s+numObsPerPage(ii));
        ind     = (ii - 1)*obj.numberOfVariables+1:ii*obj.numberOfVariables;
        if ~isempty(find(strcmp(DB.dataNames{ii},obj.dataNames),1))
            exp = regexp(DB.dataNames{ii},'Database[0-9]+','match');
            if isempty(exp)
                obj = obj.addDataset(dataset, [DB.dataNames{ii} '(2)'], DB.startDate, DB.locations(:,ind),DB.indicator, DB.variables);
            else
                obj = obj.addDataset(dataset, '', DB.startDate, DB.locations(:,ind),DB.indicator, DB.variables);
            end
        else
            obj = obj.addDataset(dataset, DB.dataNames{ii}, DB.startDate, DB.locations(:,ind),DB.indicator, DB.variables);
        end
        s = s + numObsPerPage(ii);
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

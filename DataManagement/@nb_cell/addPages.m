function obj = addPages(obj,DB,varargin)
% Syntax:
%
% obj = addPages(obj,DB)
%
% Description:
%
% Add all pages from a different nb_cell object with the current
% one
% 
% Caution : This method will break the link to the data source of 
%           updateable objects!
%
% Input:
% 
% - obj      : An object of class nb_cell
% 
% - DB       : An object of class nb_cell
%
% - varargin : Optional number of objects of class nb_cell
% 
% Output:
% 
% - obj : An object of class nb_cell with all the datasets from the 
%         objects obj and varargin.
%
%         Be aware: Objects will be expanded with nans to match sizes.
% 
% Examples:
%
% obj = addPages(obj,DB);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isa(DB,'nb_cell') || ~isa(obj,'nb_cell')
        error([mfilename ':: The added pages must both be nb_cell objects.'])
    end
    
    for ii = 1:DB.numberOfDatasets

        if ~isempty(find(strcmp(DB.dataNames{ii},obj.dataNames),1))

            exp = regexp(DB.dataNames{ii},'Database[0-9]+','match');

            if isempty(exp)
                error([mfilename ':: You can not add pages of two nb_cell objects with the same data names. I.e. ' DB.dataNames{ii}])
            else
                obj = obj.addDataset(DB.cdata(:,:,ii), '');
            end
        else
            obj = obj.addDataset(DB.cdata(:,:,ii), DB.dataNames{ii});
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

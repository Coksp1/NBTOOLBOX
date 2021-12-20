function obj = addDatasets(datasets,NameOfDatasets)
% Syntax:
%
% obj = addDatasets(datasets,NameOfDatasets)
%
% Makes it possible to add more datasets to a existing nb_cell object
% 
% Input:
% 
% Same input as of the constructor but only cell arrays are 
% supported for the inputs 'datasets' and 'NameOfDatasets'. 
% 'NameOfDatasets' could be given as a empty cell; {};
%                    
% Output:
% 
% - obj : An object of class nb_cell, now including the new datasets 
%         provided
% 
% Examples:
% 
% obj = addDatasets({'excel1','excel2'},{},{'First'})
%
% Written by Kenneth S. Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        NameOfDatasets = {};
        if nargin < 2
           datasets = {}; 
        end
    end

    if ~iscell(datasets) && ~isempty(datasets)
       error([mfilename ':: The input datasets must be a cell of the added datasets; either dyn_ts object(s), xls(x) file(s), mat file(s) or '...
                        'a double matrix (then the variables must also be given)']) 
    end

    if ~iscell(NameOfDatasets) && ~isempty(NameOfDatasets)
       error([mfilename ':: The input ''NameOfDatasets'' must be a cell with the names of the added datasets. Can also be empty; i.e. {}.']) 
    end

    for jj = 1:size(datasets,2)

        % Collect data from the different datasets. (Exspands
        % data if not of same dates and variables; empty data
        % will be set as nans)
        if ischar(datasets{jj}) || iscell(datasets{jj})

            % Dataset is loaded form excel spreadsheet, a 
            % .mat fil or double matrix (can have more pages)
            try
                NameOfData = NameOfDatasets{jj};
            catch Err
                if strcmp(Err.identifier,'MATLAB:badsubscript')

                    NameOfData = '';
                else
                    rethrow(Err);
                end
            end
            obj = addDataset(obj,datasets{jj}, NameOfData);

        else
            error([mfilename ':: Wrong dataset format. Must be either a struct of double matrices, the name of an excel spreadsheet or .mat file or just a double matrix.'])
        end
    end
end

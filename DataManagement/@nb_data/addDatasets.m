function obj = addDatasets(obj,datasets,NameOfDatasets,startObs,variables)
% Syntax:
%
% obj = addDatasets(obj,datasets,NameOfDatasets,startObs,...
%                   variables)
%
% Description:
%
% Makes it possible to add more datasets to a existing nb_data
% object.
% 
% Input:
% 
% Same input as of the constructor but only cell arrays are 
% supported for the inputs 'datasets' and 'NameOfDatasets'. 
% 'NameOfDatasets' could be given as a empty cell; {};
% 
% Output:
% 
% - obj : An nb_data object now with the added datasets.
% 
% Examples:
%
% See also:
% nb_data, addDataset, structure2Dataset
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 5
        variables = {};
        if nargin < 4
            startObs = '';
            if nargin < 3
                NameOfDatasets = {};
                if nargin < 2
                   datasets = {}; 
                end
            end
        end
    end
    
    if ~iscell(datasets) && ~isempty(datasets)
       error('nb_ts:addDatasets:inputMustBeACell',[mfilename ':: The input datasets must be a cell of the added datasets; either dyn_ts object(s), xls(x) file(s), mat file(s) or '...
                        'a double matrix (then the variables must also be given)']) 
    end

    if ~iscell(NameOfDatasets) && ~isempty(NameOfDatasets)
       error([mfilename ':: The input NameOfDatasets must be a cell with the names of the added datasets. Can also be empty; i.e. {}.']) 
    end

    for jj = 1:size(datasets,2)

        % Collect data from the different datasets. (Exspands
        % data if not of same dates and variables; empty data
        % will be set as nans)
        if ischar(datasets{jj})

            % Dataset is loaded form excel spreadsheet or a 
            % .mat fil
            try
                NameOfData = NameOfDatasets{jj};
            catch Err
                if strcmp(Err.identifier,'MATLAB:badsubscript')

                    NameOfData = '';
                else
                    rethrow(Err);
                end
            end

            obj = addDataset(obj,datasets{jj}, NameOfData, startObs);

        elseif isstruct(datasets{jj}) 

            NameOfDatasets = fieldnames(datasets{jj});

            % It is also possible to add a structure of dyn_ts
            % objects. Then the propert 'dataNames' will be 
            % the same as the fieldnames of this structure.
            for kk = 1:size(NameOfDatasets,1)

                if isnumeric(datasets{jj}.(NameOfDatasets{kk}))

                    obj = addDataset(obj, datasets{jj}.(NameOfDatasets{kk}), NameOfDatasets{kk}, startObs, variables);

                else
                    error([mfilename ':: If you give a structure as input to the nb_ts constuctor, it must only consist of double matrices.'])
                end

            end

        elseif isnumeric(datasets{jj})

            try
                NameOfData = NameOfDatasets{jj};
            catch 
                NameOfData = '';
            end

            obj = addDataset(obj,datasets{jj},NameOfData,startObs,variables);

        else
            error([mfilename ':: Wrong dataset format.'])
        end
        
    end

end

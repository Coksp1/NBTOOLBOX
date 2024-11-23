function obj = addDatasets(datasets,NameOfDatasets,types,variables)
% Syntax:
%
% obj = addDatasets(datasets,NameOfDatasets,types,variables)
%
% Makes it possible to add more datasets to a existing nb_cs object
% 
% Input:
% 
% Same input as of the constructor but only cell arrays are 
% supported for the inputs 'datasets' and 'NameOfDatasets'. 
% 'NameOfDatasets' could be given as a empty cell; {};
%                    
% Output:
% 
% - obj : An object of class nb_cs, now including the new datasets 
%         provided
% 
% Examples:
% 
% obj = addDatasets({'excel1','excel2'},{},{'First'},...
%                   {'Var1','Var2'})
%
% Written by Kenneth S. Paulsen 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

   % obj = addDatasets(datasets,NameOfDatasets,types,variables)

    if nargin < 5
        variables = {};
        if nargin < 4
            types = {};
            if nargin < 3
                NameOfDatasets = {};
                if nargin < 2
                   datasets = {}; 
                end
            end
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
        if ischar(datasets{jj}) || isnumeric(datasets{jj})

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

            obj = addDataset(obj,datasets{jj}, NameOfData, types, variables);


        elseif isstruct(datasets{jj}) 

            NameOfDatasets = fieldnames(datasets{jj});

            % It is also possible to add a structure of double
            % matrices. Then the propert 'dataNames' will be 
            % the same as the fieldnames of this structure.
            for kk = 1:size(NameOfDatasets,1)

                if isnumeric(datasets{jj}.(NameOfDatasets{kk}))

                    obj = addDataset(obj, datasets{jj}.(NameOfDatasets{kk}), NameOfDatasets{kk}, types, variables);

                else
                    error([mfilename ':: If you give a structure as input to the nb_cs constuctor, it can only consist of double matrices.'])
                end

            end

        else
            error([mfilename ':: Wrong dataset format. Must be either a struct of double matrices, the name of an excel spreadsheet or .mat file or just a double matrix.'])
        end
    end
end

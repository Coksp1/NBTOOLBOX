function obj = addDatasets(datasets,nameOfDatasets,dates,variables)
% Syntax:
%
% obj = addDatasets(datasets,nameOfDatasets,dates,variables)
%
% Makes it possible to add more datasets to a existing nb_bd object
% 
% Input:
% 
% Same input as of the constructor but only cell arrays are 
% supported for the inputs 'datasets' and 'nameOfDatasets'. 
% 'nameOfDatasets' could be given as a empty cell; {};
%                    
% Output:
% 
% - obj : An object of class nb_bd, now including the new datasets 
%         provided
% 
% Examples:
% 
% obj = addDatasets({'2019Q1','2019Q2'},{},{'First'},...
%                   {'Var1','Var2'})
%
% Written by Kenneth S. Paulsen 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 5
        variables = {};
        if nargin < 4
            startDate = '';
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
        if  isa(datasets{jj},'dyn_ts')

            % If the dataset jj is of class dyn_ts we must
            % asign it a name, this will either be the input 
            % NameOfDataset{jj} or 'Database jj'. Else the
            % datset name is dataset{jj}.
            try
                NameOfData = NameOfDatasets{jj};
            catch Err
                if strcmp(Err.identifier,'MATLAB:badsubscript')
                    NameOfData = '';
                else
                    rethrow(Err);
                end
            end
            obj = addDataset(obj,datasets{jj}, NameOfData, startDate);

        elseif ischar(datasets{jj})

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
            obj = addDataset(obj,datasets{jj}, NameOfData, startDate);

        elseif isstruct(datasets{jj}) 

            NameOfDatasets = fieldnames(datasets{jj});

            % It is also possible to add a structure of dyn_ts
            % objects. Then the propert 'dataNames' will be 
            % the same as the fieldnames of this structure.
            for kk = 1:size(NameOfDatasets,1)

                if isa(datasets{jj}.(NameOfDatasets{kk}),'nb_ts')
                
                    DB           = datasets{jj}.(NameOfDatasets{kk});
                    DB.dataNames = NameOfDatasets(kk);
                    obj          = obj.addPages(DB);
                    
                elseif isa(datasets{jj}.(NameOfDatasets{kk}),'dyn_ts')

                    obj = addDataset(obj, datasets{jj}.(NameOfDatasets{kk}), NameOfDatasets{kk}, startDate);

                elseif isnumeric(datasets{jj}.(NameOfDatasets{kk}))

                    obj = addDataset(obj, datasets{jj}.(NameOfDatasets{kk}), NameOfDatasets{kk}, startDate, variables);

                else
                    error([mfilename ':: If you give a structure as input to the nb_ts constuctor, it must only consist of dyn_ts object(s) or '...
                                     'double matrices.'])
                end

            end

        elseif isnumeric(datasets{jj})

            try
                NameOfData = NameOfDatasets{jj};
            catch  %#ok<CTCH>
                NameOfData = '';
            end
            obj = addDataset(obj,datasets{jj},NameOfData,startDate,variables);

        else
            error([mfilename ':: Wrong dataset format.'])
        end
        
    end

end


function nb_updateModels(path,varargin)
% Syntax:
%
% nb_updateModels(path,varargin)
%
% Description:
%
% Update a set of models (of class nb_model_forecast_vintages) stored as
% .mat files in the provided folder.
% 
% Input:
% 
% - path : The full path to the folder containing the models to update.
%          If not provided the current path is used.
%
% Optional input:
%
% - 'oneByOne' : true or false. Default is false. If true, you need to 
%                organize the update in an order of the hierarchy of your 
%                models, i.e. the models with level 0 first, then level 1, 
%                and so on.
%
% - 'order'    : Provide the order of the models to update.
%
% - varargin   : The rest of the options will be given to the update method 
%                of the nb_model_forecast_vintages class.
%
% 
% See also:
% nb_model_forecast_vintages, nb_model_vintages, nb_model_group_vintages
% nb_model_forecast_vintages.update
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Load model objects from path
    if nargin < 1
        d = dir();
    else
        d = dir(path);
    end
    [order,varargin] = nb_parseOneOptional('order',{},varargin{:});
    if isempty(order)
        names  = {d.name};
        names  = names(~[d.isdir]);
        matInd = nb_contains(names,'.mat');
        names  = names(matInd);
    else
        names  = order;
    end
    nModels             = length(names);
    folder              = d(1).folder;
    [oneByOne,varargin] = nb_parseOneOptional('oneByOne',false,varargin{:});
    
    if oneByOne
        
        [parallel,varargin]    = nb_parseOneOptionalSingle('parallel',0,1,varargin{:});
        [waitbar,varargin]     = nb_parseOneOptionalSingle('waitbar',0,1,varargin{:});
        [cores,varargin]       = nb_parseOneOptional('cores',[],varargin{:});
        [fileToWrite,varargin] = nb_parseOneOptional('fileToWrite','',varargin{:});
        [write,~]              = nb_parseOneOptionalSingle('write',false,true,varargin{:});
        if isempty(fileToWrite) && ~parallel && write
            fileNameToWrite = [folder,'\errors',filesep(),'errorReportUpdate_' nb_clock('vintage') '.txt'];
            if ~exist([folder,'\errors'],'dir')
                mkdir([folder,'\errors']);
            end
            fileToWrite = fopen(fileNameToWrite,'a');
            if fileToWrite == -1
                error([mfilename ':: Cannot open the error file; ' fileNameToWrite '. Please change the userpath!']);
            end
        elseif ~isempty(fileToWrite) && parallel
            error('Cannot set fileToWrite options when parallel is set to true.')
        end
        if write
            updateFunc = @(x)updateOne(x,'fileToWrite',fileToWrite,'write');
        else
            updateFunc = @(x)updateOne(x);
        end
        
        if parallel && waitbar
        
            [useNew,D] = nb_parCheck();
            if ~useNew 
                error('To set parallel to true is only supported for a MATLAB version that support the parallel.pool.DataQueue class.')
            end
            ret = nb_openPool(cores);
            
            % Create waitbar and create notify function
            h      = nb_waitbar([],'Updating...',nModels,false,false);
            afterEach(D,@(x)nb_updateWaitbarParallel(x,h));
            
            parfor ii = 1:nModels
                
                % Load model object
                model = nb_load([folder,filesep,names{ii}]);
                if isempty(model.path)
                    error([mfilename ':: The model object must be saved down using the path property and the ',...
                                 'nb_model_update_vintages.saveObject method.'])
                end

                % Update model (the updated model will be saved down to the 
                % provided path in the process)
                feval(updateFunc,model);
                
                % Update waitbar
                send(D,1); 
                
            end
            
            delete(h);
            nb_closePool(ret);
            
        elseif parallel 
            
            ret = nb_openPool(cores);
            parfor ii = 1:nModels
                
                % Load model object
                model = nb_load([folder,filesep,names{ii}]);
                if isempty(model.path)
                    error([mfilename ':: The model object must be saved down using the path property and the ',...
                                 'nb_model_update_vintages.saveObject method.'])
                end

                % Update model (the updated model will be saved down to the 
                % provided path in the process)
                feval(updateFunc,model);
                
            end
            nb_closePool(ret);
            
        elseif waitbar
            
            h                = nb_waitbar5([],'Updating...',true);
            h.maxIterations1 = nModels;
            notify           = nb_when2Notify(nModels);
            
            for ii = 1:nModels

                % Load model object
                model = nb_load([folder,filesep,names{ii}]);
                if isempty(model.path)
                    error([mfilename ':: The model object must be saved down using the path property and the ',...
                                 'nb_model_update_vintages.saveObject method.'])
                end

                % Update model (the updated model will be saved down to the 
                % provided path in the process)
                updateFunc(model);
                if rem(ii,notify) == 0
                    h.status1 = ii;  
                end
                
            end
            delete(h);
            
        else
            
            for ii = 1:nModels

                % Load model object
                model = nb_load([folder,filesep,names{ii}]);
                if isempty(model.path)
                    error([mfilename ':: The model object must be saved down using the path property and the ',...
                                 'nb_model_update_vintages.saveObject method.'])
                end

                % Update model (the updated model will be saved down to the 
                % provided path in the process)
                updateFunc(model);

            end
            
        end
        
    else
       
        models = nb_model_vintages.initialize(1,nModels);
        for ii = 1:nModels
            models(ii) = nb_load([d(1).folder,filesep,names{ii}]);
        end
        ind = cellfun(@isempty,{models.path});
        if any(ind)
            error([mfilename ':: The model object must be saved down using the path property and the ',...
                             'nb_model_update_vintages.saveObject method.'])
        end

        % Update models (the updated models will be saved down to the provided
        % path in the process)
        update(models,varargin{:});
        
    end
    
end

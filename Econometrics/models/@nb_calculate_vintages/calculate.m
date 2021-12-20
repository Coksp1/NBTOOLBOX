function obj = calculate(obj,varargin)
% Syntax:
%
% obj = calculate(obj,varargin)
%
% Description:
%
% Calculate the series using the model(s) represented by 
% nb_calculate_vintages object(s).
% 
% Input:
%
% - obj        : A vector of nb_calculate_vintages objects.
%
% - 'parallel' : Use this string as one of the optional inputs to run the
%                estimation in parallel.
%
% - 'cores'    : The number of cores to open, as an integer. Default
%                is to open max number of cores available. Only an 
%                option if 'parallel' is given. 
%
% - 'waitbar'  : Use this string to give a waitbar during estimation. I.e.
%                when looping over models.
%
% - 'write'    : Use this option to write errors to a file instead of 
%                throwing the error.
%
% Optional input:
% 
% - varargin : See the the set method.
% 
% Output:
% 
% - obj   : A vector of nb_calculate_vintages objects, where the 
%           estimation results are stored in the property
%           results.
%
% See also:
% nb_calculate_vintages
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Interpret inputs
    [inputs,others] = nb_model_generic.parseOptional(varargin{:});
    inputs          = nb_logger.openLoggerFile(inputs,obj);
    obj             = set(obj,others{:});
    obj             = obj(:);
    nobj            = size(obj,1);
    if nobj == 0
        return
    end
    
    if ~isa(obj.options.dataSource,'nb_modelDataSource')
        error('The dataSource must be an object of class nb_modelDataSource.')  
    end
    
    % Get the update level
    if obj.level == 0
        obj = updateLevel(obj);
    end

    % Get the number of contexts/vintages of each model to 
    % do the estimation on
    %------------------------------------------------------
    names     = getModelNames(obj);
    nContexts = nan(1,nobj);
    for ii = 1:nobj
        
        if ~isa(obj(ii).options.dataSource,'nb_modelDataSource')
            error([mfilename ':: The dataSource option cannot be empty for ' names{ii} '.'])
        end
        nContexts(ii) = length(obj(ii).contexts2Run);
        
    end
    
    % Set up the estimators
    %------------------------------------------------------
    nEst = sum(nContexts);
    if nEst == 0
        return
    end
    estOpt   = cell(1,nEst);
    namesEst = estOpt;
    kk       = 1;
    for ii = 1:nobj
        
        data            = breakLink(getData(obj(ii).options.dataSource));
        model           = obj(ii).model;
        model           = set(model,'transformations',obj(ii).transformations,...
                                    'fcstHorizon',0,...
                                    'reporting',obj(ii).reporting);
        doHandleMissing = handleMissing(model);
        contexts2Run    = obj(ii).contexts2Run;
        for jj = 1:nContexts(ii)
            
            % Assign the data and do transformations and reporting
            context = keepPages(data,contexts2Run{jj});
            model   = set(model,'data',context); % This will trigger set.dataOrig which will do transformations and reporting
                        
            % Get the estimation option for each model and context
            estOpt(kk)                 = getEstimationOptions(model);
            estOpt{kk}.recursive_estim = true;
            estOpt{kk}.context         = contexts2Run{jj};
            if doHandleMissing
                estOpt{kk}.recursive_estim_start_ind = model.options.data.getRealEndDate('nb_date','any') - model.options.data.startDate + 1;
                estOpt{kk}.estim_end_ind             = estOpt{kk}.recursive_estim_start_ind;
            else
                estOpt{kk}.recursive_estim_start_ind = model.options.data.getRealEndDate('nb_date','all') - model.options.data.startDate + 1;
                estOpt{kk}.estim_end_ind             = estOpt{kk}.recursive_estim_start_ind;
            end
            namesEst{kk} = [names{ii}, '(At context: ' contexts2Run{jj} ')'];
            kk           = kk + 1;
            
        end
        
    end

    % Estimate the model(s)
    %------------------------------------------------------
    [res,estOpt] = nb_model_generic.loopEstimate(estOpt,namesEst,inputs);
     
    % Assign objects
    %------------------------------------------------------
    kk = 1;
    for ii = 1:nobj 
        
        if obj(ii).giveErrorEstimation
            if ii == 1
                res{nContexts(ii) - 2} = [];
            end
        end
        
        obj(ii).contexts2Write = obj(ii).contexts2Run;
        if ~isfield(obj(ii).results,'data')
            obj(ii).results.data = nb_ts();
        end
        valid = true(1,nContexts(ii));
        for jj = 1:nContexts(ii)
            if isempty(res{kk})
                valid(jj) = false;
            else
                obj(ii) = getCalcFromResults(obj(ii),res{kk},estOpt{kk},obj(ii).contexts2Run{jj});
            end
            kk = kk + 1;
        end
        
        if nContexts(ii) > 0
            
            % Check that estimation has been done for all contexts
            if isempty(obj(ii).results.data)
                obj(ii).valid = false;
            else
                ind = ismember(obj(ii).contexts2Run,obj(ii).results.data.dataNames);
                if all(ind)
                    obj(ii).contexts2Run = {};
                    obj(ii).valid        = obj(ii).valid && true;
                else
                    % Some context failed, so we just keep the failed once
                    % until the problem may be fixed...
                    obj(ii).contexts2Run = obj(ii).contexts2Run(~ind);
                    obj(ii).valid        = false;
                end
                
            end
                       
        end
         
    end
    
    % Close written file
    nb_logger.closeLoggerFile(inputs);
    
end

%==========================================================================
% function model = sortContexts(model)
% % In case on or more context have been failing, and they have been fixed,
% % the ordering may not be correct, so we sort them to be sure of that...
% 
%     [model.results.context,ind] = sort(model.results.context); 
%     fields                      = fieldnames(model.results);
%     for ii = 1:length(fields)
%         if isnumeric(model.results.(fields{ii})) && size(model.results.(fields{ii}),3) > 1
%             model.results.(fields{ii}) = model.results.(fields{ii})(:,:,ind);
%         end
%     end
%     
% end

function obj = filter(obj,varargin)
% Syntax:
%
% obj = filter(obj,varargin)
%
% Description:
%
% Filter the data with the mean parameter estimates. The default is to
% filter over the estimation sample, but it is possible to adjust the
% filtering sample by setting 'estim_start_date' and 'estim_end_date'.
% 
% Input:
% 
% - obj : An object of class nb_mfvar.
%
% Optional input:
%
% - 'waitbar' : Provide this one line char to make a waitbar when looping
%               the method over different models.
%
% - Given to the nb_model_estimate.set metod. See description on relevant
%   options to adjust.
% 
% Output:
% 
% - obj : An object of class nb_mfvar, where the filtering results are
%         stored in the results property. 
%
% See also:
% nb_model_generic.getFiltered
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        [waitbar,varargin] = nb_parseOneOptionalSingle('waitbar',false,true,varargin{:});
        if waitbar
            h   = nb_waitbar5([],'Filter');
            obj = nb_callMethodWaitbar(obj,@filter,@nb_mfvar,h,varargin{:});
            delete(h);
        else
            obj = nb_callMethod(obj,@filter,@nb_mfvar,varargin{:});
        end
        return
    end

    if ~isestimated(obj)
        error([mfilename ':: All models must first be estimated.'])
    end
    
    % Set properties
    obj = set(obj,varargin{:});

    % Get estimation options 
    options = getEstimationOptions(obj);
    options = options{1};
    
    % Check if we have a block_exogenous model
    restrictions = {};
    if isfield(options,'block_exogenous')
        if ~isempty(options.block_exogenous)
            restrictions = nb_estimator.getBlockExogenousRestrictions(options);
        end
    end
    
    % Get data and sizes
    tempData = options.data;
    tempDep  = cellstr(options.dependent);
    if isfield(options,'block_exogenous')
       tempDep = [tempDep,options.block_exogenous];
    end
    
    if isempty(tempDep)
        error([mfilename ':: You must add the left side variable of the equation to dependent field of the options property.'])
    end
    if isempty(tempData)
        error([mfilename ':: Cannot estimate without data.'])
    end
    [test,indY] = ismember(tempDep,options.dataVariables);
    if any(~test)
        error([mfilename ':: Some of the selected dependent variables are not found in the data; ' toString(tempDep(~test))])
    end
    y           = tempData(:,indY);
    [test,indX] = ismember(options.exogenous,options.dataVariables);
    if any(~test)
        error([mfilename ':: Some of the selected exogenous variables are not found in the data; ' toString(options.exogenous(~test))])
    end
    X = tempData(:,indX);
    if isempty(y)
        error([mfilename ':: The selected sample cannot be empty.'])
    end
    
    if isempty(options.estim_start_ind)
        options.estim_start_ind = 1;
    end
    if isempty(options.estim_end_ind)
        options.estim_end_ind = find(~all(isnan(y),2),1,'last');
    end
    sample = options.estim_start_ind:options.estim_end_ind;
    y      = y(sample,:);
    X      = X(sample,:);
    nLags  = options.nLags;
    nDep   = size(y,2) - sum(options.indObservedOnly);
    
    % Add time trend if wanted
    Traw = size(y,1);
    if options.time_trend
        trend = 1:Traw;
        X     = [trend', X];
    end
    
    % Add constant if wanted
    if options.constant        
        X = [ones(Traw,1), X];
    end
    nExo = size(X,2);
    
    % Get the parameters
    sigma = obj.results.sigma;
    alpha = obj.results.beta(:);
    nEq   = size(obj.results.beta,2);
    if ~isempty(restrictions)
        restr = [restrictions{:}];
        alpha = alpha(restr);
    end
    
    % Get measurement equation
    [H,~,extra] = nb_mlEstimator.getMeasurementEqMFVAR(options,1);
    
    % Get needed posterior information
    if any(~options.indObservedOnly)
        if isfield(obj.results,'R')
            R_prior = obj.results.R;
        else
            try
                posterior = nb_loadDraws(obj.estOptions.pathToSave);
            catch Err
                nb_error('It seems to me that the estimation results has been saved in a folder you no longer have access to. Error::',Err)
            end
            R_prior = posterior(end).R_prior;
        end
    else
        R_prior = zeros(nDep,1); % Prior on measurement error variance 
    end
    
    % Do the filtering
    [~,ys,residual,~,yu] = nb_kalmansmoother_missing(@nb_bVarEstimator.getStateSpace,y',X',alpha,sigma,nEq,nLags,nExo,restrictions,H,R_prior);

    % Store results
    dataStart                   = obj.options.data.startDate;
    obj.results.filterStartDate = toString(dataStart + options.estim_start_ind - 1);
    obj.results.filterEndDate   = toString(dataStart + options.estim_end_ind - 1);
    obj.results.realTime        = false;

    if extra
        H  = H(:,1:nDep*nLags,:);
        ys = ys(:,1:nDep*nLags);
        yu = yu(:,1:nDep*nLags);
    end
    
    % Append the low frequency smoothed variables
    [ys,allEndo,exo] = nb_bVarEstimator.getAllMFVariables(options,ys,H,tempDep,true);
    [yu]             = nb_bVarEstimator.getAllMFVariables(options,yu,H,tempDep,true);

    % Store smoothed results
    obj.results.smoothed.variables = struct('data',ys,'startDate',obj.results.filterStartDate,'variables',{allEndo});
    obj.results.smoothed.shocks    = struct('data',residual,'startDate',obj.results.filterStartDate,'variables',{exo});
    obj.results.updated.variables  = struct('data',yu,'startDate',obj.results.filterStartDate,'variables',{allEndo});
    
    % Update estimation sample period
    obj.estOptions.estim_start_ind = options.estim_start_ind;
    obj.estOptions.estim_end_ind   = options.estim_end_ind;
    obj.estOptions.data            = options.data;
    obj.estOptions.dataStartDate   = options.dataStartDate;
    obj.estOptions.dataVariables   = options.dataVariables;
    
end

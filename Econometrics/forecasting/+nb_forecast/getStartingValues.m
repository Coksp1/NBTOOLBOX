function Y0 = getStartingValues(startingValues,options,solution,results,last)
% Syntax:
%
% Y0 = nb_forecast.getStartingValues(startingValues,options,solution,...
%           results,last)
%
% Description:
%
% Get the selected starting values. 
% 
% See also:
% nb_forecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(last)
        if isfield(options,'estim_end_ind')
            last = options(end).estim_end_ind;
        else
            last = 1;
        end
    else
        if numel(options) > 1
            if last > options(end).estim_end_ind
                date = nb_date.date2freq(options(end).dataStartDate) + (last - 1);
                error([mfilename ':: When dealing with real-time data no starting value can be located at ' toString(date) ])
            end
        else
            if last > size(options.data,1)
                date = nb_date.date2freq(options(end).dataStartDate) + (last - 1);
                error([mfilename ':: No starting value can be located at ' toString(date) '. Outside the window of the data.'])
            end
        end
    end

    if strcmpi(solution.class,'nb_sa') || strcmpi(solution.class,'nb_tvp') 
        
        try
            periods = last - options(1).estim_start_ind + 1;
        catch %#ok<CTCH>
            periods = 1;
        end
        Y0 = nan(periods,1);
        return
          
    elseif strcmpi(solution.class,'nb_fmsa')
        
        try
            factors = solution.factors;
        catch %#ok<CTCH>
            error([mfilename ':: The model is not solved or the input model does not include the needed fields.'])
        end
        [~,indY] = ismember(factors,options(end).dataVariables);
        if numel(options) > 1 % Real-time forecast
            periods = numel(options);
            Y0      = nan(periods-1,numel(indY));
            for ii = 2:periods
                Y0(ii-1,:) = options(ii).data(options(ii).estim_end_ind,indY);
            end
            Y0 = [options(1).data(options(1).estim_start_ind:options(1).estim_end_ind,indY);Y0]; 
        else
            Y0 = options.data(options.estim_start_ind:last,indY);
        end
        return
        
    end

    endo = solution.endo;
    if isempty(startingValues)
        
        % Default starting values
        if isfield(results,'smoothed')
            
            if options(end).real_time_estim
                error([mfilename ':: Real-time estimation of model using kalman filter is not yet finished for forecating.'])
            elseif options(end).recursive_estim
                % Here we use the recursive end point from the filtering
                T         = options(end).estim_end_ind - options(end).estim_start_ind + 1; 
                Y0        = nan(T,size(results.ys0,2));
                ind       = options(end).recursive_estim_start_ind - options(end).estim_start_ind + 1:T;
                Y0(ind,:) = permute(results.ys0,[3,2,1]);
                if size(Y0,2) > length(solution.endo)
                    Y0 = Y0(:,1:length(solution.endo));
                end
            else
                [~,indY] = ismember(endo,results.smoothed.variables.variables);
                YReg     = results.smoothed.variables.data(:,indY,:);
                if nb_isModelMarkovSwitching(solution)
                    % Get econometricians view of the smoothed variables
                    regProb  = results.smoothed.regime_probabilities.data;
                    Y0       = zeros(size(YReg,1),size(YReg,2));
                    for ii = 1:size(YReg,3)
                        Y0 = Y0 + bsxfun(@times,YReg(:,:,ii),regProb(:,ii));
                    end
                else
                    Y0 = YReg;
                end
                
                % Filter start date may be different than the estimation
                % start date, so make robust to this case here!
                dataStart = nb_date.date2freq(options.dataStartDate);
                estStart  = dataStart + (options.estim_start_ind - 1);
                filtStart = nb_date.toDate(results.filterStartDate,dataStart.frequency);
                filtLag   = filtStart - estStart;
                Y0        = [nan(filtLag,size(Y0,2));Y0];
                
            end
            
        else
            [~,indY] = ismember(endo,options(end).dataVariables);
            if numel(options) > 1 % Real-time forecast or missingMethod is used
                periods = numel(options);
                Y0      = nan(periods-1,numel(indY));
                for ii = 2:periods
                    Y0(ii-1,:) = options(ii).data(options(ii).estim_end_ind,indY);
                end
                Y0 = [options(1).data(options(1).estim_start_ind:options(1).estim_end_ind,indY);Y0]; 
            else
                Y0 = options.data(options.estim_start_ind:last,indY);
            end    
        end
        
    else % Starting from another point than default
        
        try
            if isempty(options(end).estim_end_ind)
                periods = 1;
            else
                periods = last - options(1).estim_start_ind + 1;
            end
        catch %#ok<CTCH>
            periods = 1;
        end
        
        nVar = length(endo);
        if isnumeric(startingValues)

            if size(startingValues,2) ~= nVar
                error([mfilename ':: The dimension 2 of the provided starting values must match the number of dependent variables of the model. '...
                    '(See solution.endo for a list of the variables you need to assign starting values.)'])
            elseif size(startingValues,1) ~= 1 && size(startingValues,1) ~= periods
               error([mfilename ':: The dimension 1 of the provided starting values must match the number of periods (' int2str(periods) '.) to forecast from, '...
                    'or be 1.']) 
            end
            
            if size(startingValues,1) == 1
                Y0 = startingValues(ones(1,periods),:);
            else
                Y0 = startingValues;
            end
                
        elseif ischar(startingValues)
            
            % Check which steady state to begin from (MS-models)
            out = regexp(startingValues,'(','split');
            if size(out,2) == 2
                startingValues = out{1};
                ssInd          = out{2};
                ssInd          = str2double(ssInd(1:end-1));
            else
                ssInd = [];
            end
            
            switch lower(startingValues)
                
                case 'mean'
                    
                    if isfield(results,'smoothed_variables')
                        error([mfilename ':: The startingValue option ''mean'' is not an option for filtered models.'])
                    end
                    [~,indY] = ismember(endo,options.dataVariables);
                    data     = options.data(options.estim_start_ind:options.estim_end_ind,indY);
                    Y0       = nanmean(data,1);
                    Y0       = Y0(ones(1,periods),:);
                    
                case 'zero'
                    Y0 = zeros(periods,nVar);
                case 'steadystate' 
                
                    if strcmpi(solution.class,'nb_dsge')
                        
                        if nb_isModelMarkovSwitching(solution)
                            if isempty(ssInd)
                                ss = ms.integrateOverRegime(solution.Q,solution.ss);
                            else
                                ss = solution.ss{ssInd};
                            end
                        elseif iscell(solution.ss) % Model with break-points
                            if isempty(ssInd)
                                ss = solution.ss{end};
                            else
                                ss = solution.ss{ssInd};
                            end
                        else
                            ss = solution.ss;
                            if isfield(options,'stochasticTrendInit') && ~nb_isempty(options.parser)
                                stInit = nb_dsge.interpretStochasticTrendInit(options.parser,options.stochasticTrendInit,results.beta);
                                ss     = ss + stInit;
                            end
                        end
                        ss = full(ss)';
                        Y0 = ss(ones(1,periods),:);
                        
                    else
                        error([mfilename ':: The steadyState option is not valid for the model class ' solution.class])
                    end
                    
                case 'updated'
                    
                    if ~isfield(results,'updated')
                        error([mfilename ':: Setting the ''startingValues'' to ''updated'' is not possible as no updated ',...
                                         'estimates of the states are stored in the results property.'])
                    end
                    if options(end).real_time_estim
                        error([mfilename ':: Real-time estimation of model using kalman filter is not yet finished for forecating.'])
                    elseif options(end).recursive_estim
                        error([mfilename ':: Setting the ''startingValues'' to ''updated'' is not supported for recursivly estimated models.'])
                    else
                        [~,indY] = ismember(endo,results.updated.variables.variables);
                        YReg     = results.updated.variables.data(:,indY,:);
                        if nb_isModelMarkovSwitching(solution)
                            % Get econometricians view of the smoothed variables
                            regProb  = results.updated.regime_probabilities.data;
                            Y0       = zeros(size(YReg,1),size(YReg,2));
                            for ii = 1:size(YReg,3)
                                Y0 = Y0 + bsxfun(@times,YReg(:,:,ii),regProb(:,ii));
                            end
                        else
                            Y0 = YReg;
                        end
                    end
                    
                otherwise
                    error([mfilename ':: Improper string assign to startingValues; ' startingValues])
            end
            
        else 
            error([mfilename ':: The input startingValues must be either a string or a double.'])
        end
        
    end
    
end

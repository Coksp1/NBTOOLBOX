function dep = getForecastVariables(options,model,inputs,type)
% Syntax:
%
% dep = nb_forecast.getForecastVariables(options,model,inputs,type)
%
% Description:
%
% Get forecast variables from model
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if any(strcmpi(model.class,{'nb_sa','nb_midas','nb_fmsa'}))
        dep = unique(regexprep(options(end).dependent,'_{0,1}lead[0-9]*$',''));
    elseif strcmpi(model.class,'nb_ecm')
        dep = model.endo; 
    elseif strcmpi(model.class,'nb_tvp')
        dep = model.observables;  
    elseif strcmpi(model.class,'nb_mfvar')
        if strcmpi(type,'pointForecast') || strcmpi(type,'densityForecast')
            dep = model.endo;
        else
            if strcmpi(inputs.output,'fullendo')  || strcmpi(inputs.output,'full')
                % Also include lags
                dep = [options(end).dependent,model.endo];
            else
                % Here the lags are not returned.
                dep = [options(end).dependent, options(end).block_exogenous];
                if isfield(options,'measurementEqRestriction') && ...
                            ~nb_isempty(options.measurementEqRestriction)
                    restr = unique({options.measurementEqRestriction.restricted}); 
                    indR  = ~ismember(restr,dep);
                    restr = restr(indR);    
                    dep   = [dep,restr];
                end
                if size(options.indObservedOnly,2) == length(dep)
                    % Normal B-VAR where measurement restrictions are
                    % taken into account during estimation
                    remove = sum(options.indObservedOnly);
                else
                    remove = sum(options.indObservedOnly) + length(restr); 
                end
                nDep = length(dep) - remove;
                dep  = [dep, model.endo(1:nDep)];
                if ~isempty(inputs.observables)
                    [~,ind] = ismember(inputs.observables,model.observables);
                    if size(ind,2) ~= size(model.observables,2)
                        ind = [ind, size(dep,2)-nDep+1:size(dep,2)];
                        dep = dep(ind);
                    end
                end
            end
        end
    else
        if strcmpi(inputs.output,'fullendo')  || strcmpi(inputs.output,'full') 
            if strcmpi(model.class,'nb_arima')
                dep = [options(end).dependent,model.endo];
            else
                dep = model.endo;
            end
        elseif strcmpi(model.class,'nb_fmdyn') % Dynamic Factor model
            dep = model.endo(1:options.nFactors);
            if ~(strcmpi(type,'pointForecast') || strcmpi(type,'densityForecast'))
                % In point forecast these are added later on
                if isempty(inputs.observables)
                    dep = [dep,model.observables];
                else
                    dep = [dep,inputs.observables];
                end
            end
        else
            if isfield(options,'dependent')
                dep = options(end).dependent;
            else
                dep = model.endo;
            end
            if isfield(options,'block_exogenous')
                dep = [dep,options(end).block_exogenous];
            end
            if isfield(options,'measurementEqRestriction') && ...
                            ~nb_isempty(options(end).measurementEqRestriction)
                if strcmpi(type,'pointForecast') || strcmpi(type,'densityForecast')
                    dep = [dep,{options.measurementEqRestriction.restricted}];
                else
                    restr = unique({options.measurementEqRestriction.restricted}); 
                    indR  = ~ismember(restr,dep);
                    restr = restr(indR);
                    dep   = [dep,restr]; 
                end
            end
        end
        
        if strcmpi(model.class,'nb_pitvar')
            dep = strrep(dep,'_normal','');
        end
        
        if strcmpi(model.class,'nb_favar')% F-VAR
            dep = [dep,options(end).factors];
            if ~(strcmpi(type,'pointForecast') || strcmpi(type,'densityForecast'))
                % In point forecast these are added later on
                if isempty(inputs.observables)
                    dep = [dep,model.observables];
                else
                    dep = [dep,inputs.observables];
                end
            end
        end
        
    end
    
    if strcmpi(type,'all')
        
        % Markov switching model
        if nb_isModelMarkovSwitching(model)      
            dep = [dep,'states',model.regimes];
        end
        
        if ~isempty(inputs.reporting)
            dep = [dep,inputs.reporting(:,1)']; % Include reported variables as well
        end
        
        if or(strcmpi(inputs.output,'all'), strcmpi(inputs.output,'full'))
            if any(strcmpi(model.class,{'nb_sa','nb_midas','nb_fmsa'}))
                return
            end
            if strcmpi(model.class,'nb_arima')
                dep = [dep,model.exo,model.factors,model.res];
            elseif strcmpi(model.class,'nb_tvp')
                dep = [dep,model.factors,model.res,model.parameters,model.paramRes];
            else
                dep = [dep,model.exo,model.res];
            end
        end   
        
    end
    
end

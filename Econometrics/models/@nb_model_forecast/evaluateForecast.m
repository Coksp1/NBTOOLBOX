function obj = evaluateForecast(obj,varargin)
% Syntax:
%
% obj = evaluateForecast(obj,varargin)
%
% Description:
%
% Evalaute forecast using (a) selected loss function(s)
%
% Input:
%
% - obj              : An object of class nb_model_generic.
%
% Optional Input:
% 
% - 'draws'          : Number of draws used when simulating from the
%                      distribution. Default is 1000.
%
% - 'fcstEval'       : See the documentation of the same input in the 
%                      forecast method.
% 
% - 'compareToRev'   : See the documentation of the same input in the 
%                      forecast method.
%
% - 'compareTo'      : See the documentation of the same input in the 
%                      forecast method.
%
% Output:
% 
% - obj              : An object of class nb_model_generic.
%
% See also:
% nb_model_generic.forecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    test = isforecasted(obj);
    test = test(:);
    if any(~test)
        names = getModelNames(obj);
        error([mfilename ':: The model(s) has/have not produced any forecast; ' toString(names(test))]);
    end
    
    if numel(obj) > 1
        
        [s1,s2,s3] = size(obj);
        nobj       = s1*s2*s3;
        obj        = obj(:);
        for ii = 1:nobj
            obj(ii) = evaluateForecast(obj(ii),varargin{:});
        end
        obj = reshape(obj,[s1,s2,s3]);
        return
        
    end
    
    % Parse inputs
    default          = {'bins',              [],        {@iscell,'||',@isempty};...
                        'draws',             1000,      {@nb_isScalarInteger,'&&',{@gt,0}};...
                        'estimateDensities', true,      @nb_isScalarLogical;...
                        'estDensity',        'kernel'   @nb_isOneLineChar;...
                        'compareToRev',      [],        {@nb_isScalarInteger,'&&',{@gt,0},'||',@isempty};...
                        'compareTo',         [],        {@iscellstr,'||',@isempty};...
                        'fcstEval',          '',        {@iscellstr,'||',@ischar}};   
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    if ischar(inputs.fcstEval)
        inputs.fcstEval = cellstr(inputs.fcstEval);
    end
    ind = nb_ismemberi(inputs.fcstEval,{'se','abs','diff','logscore'});
    if any(~ind)
        error([mfilename ':: Unsupported forecast evaluation(s); ' toString(inputs.fcstEval(~ind))])
    end
    ind             = nb_ismemberi(inputs.fcstEval,fieldnames(obj.forecastOutput.evaluation));
    inputs.fcstEval = inputs.fcstEval(~ind);
    evalFcst        = obj.forecastOutput.evaluation;
    for ii = 1:length(inputs.fcstEval)
        evalFcst(1).(upper(inputs.fcstEval{ii})) = [];
    end
    
    % Get the actual data to compare against
    startFcst = obj.forecastOutput.start;
    nSteps    = obj.forecastOutput.nSteps + obj.forecastOutput.nowcast;
    nowcast   = obj.forecastOutput.nowcast;
    if isa(obj,'nb_model_convert')
        estOpt               = obj.options;
        estOpt.dataVariables = estOpt.data.variables;
        estOpt.dataStartDate = toString(estOpt.data.startDate);
        estOpt.data          = double(estOpt.data);
        estOpt.class         = 'nb_model_convert';
        solution             = struct('class','nb_model_convert');
        actual               = nb_model_generic.getActual(estOpt,solution,obj.forecastOutput.dependent,...
                                  startFcst,nSteps,inputs,false);
    elseif isa(obj,'nb_model_group')
        if strcmpi(obj.forecastOutput.inputs.function,'aggregateForecast')
            error([mfilename ':: Cannot evaluate a new metric of a model group that has been aggregated.'])
        end
        actual = nb_model_group.getActual(obj.models,obj.forecastOutput.dependent,...
                        startFcst,obj.forecastOutput.nSteps,inputs);
    else
        actual = nb_model_generic.getActual(obj.estOptions,obj.solution,obj.forecastOutput.dependent,...
                        startFcst,nSteps,inputs,nowcast);
    end
    
    % Get the forecast
    fcst = obj.forecastOutput.data;
    
    % Do the evaluation
    nPeriods = length(obj.forecastOutput.start);
    indDep   = ismember(obj.forecastOutput.dependent,obj.forecastOutput.variables);
    
    %Check if density.
    if isDensityForecast(obj)
        
        % Estimate density
        if ~isfield(obj.forecastOutput.evaluation(1),'density')
        
            % Do the density evaluation
            for tt = 1:nPeriods
                if inputs.estimateDensities
                    evalFcstT            = nb_evaluateDensityForecast(inputs.fcstEval,actual(:,:,tt),fcst(:,indDep,1:end-1,tt),fcst(:,indDep,end,tt),inputs);
                    evalFcst(tt).density = evalFcstT.density;
                    evalFcst(tt).int     = evalFcstT.int;
                else
                    evalFcstT = nb_evaluateDensity(inputs.fcstEval,actual(:,:,tt),[],[],fcst(:,indDep,end,tt),fcst(:,indDep,1:end-1,tt));
                end
                for ii = 1:length(inputs.fcstEval)
                    evalFcst(tt).(upper(inputs.fcstEval{ii})) = evalFcstT.(upper(inputs.fcstEval{ii}));
                end
            end
            
        else
            
            % Simulate from the estimated distribution
            if ischar(obj.forecastOutput.evaluation(1).density)
                loaded  = load(obj.forecastOutput.evaluation(1).density);
                density = loaded.density;
                domain  = loaded.domain;
            else
                density = {obj.forecastOutput.evaluation.density}; 
                domain  = {obj.forecastOutput.evaluation.int}; 
            end
            densityForSim = [density{:}];
            densityForSim = reshape(densityForSim,1,[],nPeriods);
            domainForSim  = [domain{:}];
            domainForSim  = reshape(domainForSim,1,[],nPeriods);
            forecastData  = nb_simulateFromDensity(densityForSim,domainForSim,inputs.draws);
            forecastData  = permute(forecastData,[1,2,4,3]);

            if size(obj.forecastOutput.data,1) < size(forecastData,1)
                % Remove nowcast from density forecast if no variables are 
                % missing
                forecastData = forecastData(obj.forecastOutput.nowcast+1:end,:,:,:);
            end

            % Do the density evaluation
            for tt = 1:nPeriods
                evalFcstT = nb_evaluateDensity(inputs.fcstEval,actual(:,:,tt),[],[],fcst(:,indDep,end,tt),forecastData(:,:,:,tt));
                for ii = 1:length(inputs.fcstEval)
                    evalFcst(tt).(upper(inputs.fcstEval{ii})) = evalFcstT.(upper(inputs.fcstEval{ii}));
                end
            end
            
        end
        
    else
        
        if any(strcmpi('logscore',inputs.fcstEval))
            error([mfilename ':: Cannot evalaute point forecast with logScore.'])
        end
        
        % Do the point evaluation
        for tt = 1:nPeriods
            for ii = 1:length(inputs.fcstEval)

                % Calculate forecast evaluation
                fcsEvalValue = nb_evaluateForecast(inputs.fcstEval{ii},actual(:,:,tt),fcst(:,indDep,:,tt));

                % Assign output
                evalFcst(tt).(upper(inputs.fcstEval{ii})) = fcsEvalValue;

            end
        end
        
        % Do the evaluation of the low frequency variables
        if isMixedFrequency(obj)
            
            % Get the lower frequencies.
            freqOfVars                = getFrequency(obj);
            uFreqs                    = unique(freqOfVars);
            maxFreq                   = max(uFreqs);
            uFreqs(uFreqs == maxFreq) = [];

            for ii = 1:length(uFreqs)
            
                [fcstData,fcstDates] = getForecastLowFreq(obj,uFreqs(ii),'recursive',false,obj.forecastOutput.dependent);
                fcsEvalValue         = nan(fcstData.numberOfObservations,fcstData.numberOfVariables,fcstData.numberOfDatasets,length(inputs.fcstEval));
                for vv = 1:length(fcstData.variables)
                    
                    actual = getActualLowFreq(obj,fcstData.variables(ii),uFreqs(ii),inputs.compareToRev,fcstDates,fcstData.numberOfObservations);
                    locV   = strcmpi(fcstData.variables{ii},obj.forecastOutput.dependent);
                
                    % Do the evaluation
                    for jj = 1:length(inputs.fcstEval)
                        fcsEvalValue(:,locV,:,jj) = nb_evaluateForecast(inputs.fcstEval{jj},double(actual),double(fcstData));
                    end
                    
                end
                
                % Assign output
                for jj = 1:length(inputs.fcstEval)
                    for kk = 1:size(fcsEvalValue,3)
                        evalFcst(kk).([upper(inputs.fcstEval{jj}), '_', int2str(uFreqs(ii))]) = fcsEvalValue(:,:,kk,jj);
                    end
                end
                
            end
            
        end
        
    end
    
    obj.forecastOutput.evaluation = evalFcst;
    
end

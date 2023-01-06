function [Yout,dep] = createReportedVariables(options,inputs,Y,dep,start,iter)
% Syntax:
%
% [Yout,dep] = nb_forecast.createReportedVariables(options,inputs,Y,...
%                                                   dep,start,iter)
%
% Description:
%
% Create reported variables based on simulated forecast.
% 
% See also:
% nb_forecast.pointForecast, nb_forecast.densityForecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % If we are dealing with real-time data we need to index the
    % options struct to get hold of the correct vintage of historical 
    % data
    reporting = inputs.reporting;
    if ~isempty(inputs.varOfInterest)
        if ~any(ismember(inputs.varOfInterest,reporting(:,1)))
            return
        end
    end
    
    [nSteps,~,nDraws] = size(Y);
    
    nowcast = 0;
    if isfield(inputs,'missing')
        if isempty(inputs.missing)
            nowcast = 0;
        else
            nowcast = sum(any(inputs.missing,2));
        end
    end
    endInd = start - nowcast;
    
    % Get historical values
    variables = options.dataVariables;
    dataStart = nb_date.date2freq(options.dataStartDate);
    histObs   = nb_getHistPeriodsDuringReporting(dataStart.frequency);
    try
        data      = options.data(endInd - histObs + 1:endInd,:); % 20 obs should be more than enough
        dataStart = dataStart + endInd - histObs;
    catch %#ok<CTCH>
        data = options.data(1:endInd,:); % Less then 20 observations...
    end
    data     = data(:,:,ones(1,nDraws)); % Replicate to match the number of draws of the forecast
    nHistObs = size(data,1); 
    
    % Merge with forecast
    [indM,indD]    = ismember(dep,variables);
    indD           = indD(indM); % Some variables are not part of data
    fcst           = nan(nSteps,length(variables),nDraws);
    fcst(:,indD,:) = Y(:,indM,:);
    data           = [data;fcst];
    
    % Insert for projected variables not part of model
    indNP = ismember(variables,dep);
    try %#ok<TRYNC>
        if size(options.data,1) >= endInd+nSteps
            dataP = options.data(endInd+1:endInd+nSteps,~indNP);
        else
            dataP = options.data(endInd+1:end,~indNP);
        end
        hh                                    = size(dataP,1);
        data(nHistObs+1:nHistObs+hh,~indNP,:) = dataP(:,:,ones(1,size(data,3)));
    end
    
    % Add shift variables
    if isfield(inputs,'shift')
        
        shift = inputs.shift;
        if ~isempty(shift)
            
            if size(shift,3) > 1 % Real-time de-trending
                shift = shift(:,:,iter);
            end

            [ind,indS] = ismember(inputs.shiftVariables,variables);
            indS       = indS(ind);
            try
                shiftData  = shift(endInd - histObs + 1:endInd+nSteps,ind);
            catch %#ok<CTCH>
                d = nSteps - size(shift(endInd+1:end,1),1);
                if d > 0
                    error([mfilename ':: The shift/trend data has not been forecast enough steps. Missing steps; ' int2str(abs(d)) '. '...
                                     'See the fcstHorizon input to the createVariables method, or you may need to update your data!'])
                else
                    shiftData = shift(1:endInd+nSteps,ind); % Less then 20 observations...
                    if size(shiftData,1) < size(data,1)
                        error([mfilename ':: To short estimation sample to be able to use the reporting option. Need at least ' int2str(size(data,1) - nSteps) ' observations.'])
                    end
                end
            end
            shiftData      = shiftData(:,:,ones(1,nDraws));
            data(:,indS,:) = data(:,indS,:) + shiftData;
        end
        
    end
    
    % Convert to nb_math_ts
    dataTS = nb_math_ts(data,dataStart);
    
    % Check each expressions
    if isfield(options,'context')
        contextText = ['. It is the case for the context; ', options.context];
    else
        contextText = '';
    end
    for ii = 1:size(reporting,1)
        
        expression = reporting{ii,2};
        try 
            dataTSOne = nb_eval(expression,variables,dataTS);
        catch Err
            warning('nb_forecast:createReportedVariables:couldNotEvaluate','%s',Err.message);
            continue
        end 
        if any(double(isnan(dataTSOne(nHistObs+1:end,:))))
            if nb_model_generic.isMixedFrequencyStatic(options)
                if all(double(isnan(dataTSOne(nHistObs+1:end,:))))
                    warning('nb_forecast:createReportedVariables:returnedNaN',...
                        ['The expression ' expression ' returned nan values' contextText]);
                end 
            else
                d   = dates(dataTSOne(nHistObs+1:end,:));
                ind = isnan(double(dataTSOne(nHistObs+1:end,:)));
                warning('nb_forecast:createReportedVariables:returnedNaN',['The expression ' expression ,...
                    ' returned nan values for the dates ' toString(d(ind)) contextText]);
            end
        end

        % To make it possible to use newly created variables in the 
        % expressions to come, we must append it in this way
        found = strcmp(reporting{ii,1},variables);
        if ~any(found)
            dataTS    = horzcatfast(dataTS,dataTSOne); 
            variables = [variables,reporting{ii,1}]; %#ok<AGROW>
        else
            dataTS(:,found,:) = dataTSOne;
        end
    end
    
    % Shrink variables to the dependent + reported
    indR          = ~ismember(reporting(:,1),dep);
    outVars       = [dep, reporting(indR,1)'];
    [ind,locKeep] = ismember(outVars,variables);
    locKeep       = locKeep(ind);
    outVars       = outVars(ind);
    
    % Merge reported variables with model forecast
    Yout = double(dataTS);
    Yout = Yout(nHistObs+1:end,locKeep,:);
    
    % Add forecast of variables that does not have history
    if any(~indM)
        outVars = [dep(~indM),outVars];
        Yout    = [Y(:,~indM,:),Yout];
    end
    dep = outVars;
    
end

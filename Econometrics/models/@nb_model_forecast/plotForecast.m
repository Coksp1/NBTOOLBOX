function [plotter,plotFunction2Use] = plotForecast(obj,type,startDate,increment,varargin)
% Syntax:
%
% plotter                    = plotForecast(obj)
% [plotter,plotFunction2Use] = plotForecast(obj,type,startDate,...
%                               increment,varargin)
%
% Description:
%
% Plot forecast. 
%
% Caution density forecast will only be displayed for the first model
% in the vector of nb_model_forecast objects
% 
% Input:
% 
% - obj  : A vector of nb_model_forecast objects
%
% - type : Type of plot, as a string;
%
%          > 'default'   : Plot the forcast for the last period of 
%                          estimation and ahead. Possibly with density for
%                          the first model in the model vector. Can have 
%                          different variables. If startDate is given this
%                          date will be the start of the graph instead.
% 
%          > 'hairyplot' : Plot the recursive point forecast in the same
%                          graph as the actual data.
%
% - startDate : A string with the start date of the forecast to plot. As a 
%               string or an object of class nb_date. Only an option when  
%               type is 'default'. Default is to plot the latest forecast
%               produced.
%
% - increment : Number of periods between the hairs when doing a 
%               hairy-plot. Default is 1.
%
% Optional input:
%
% - 'type'    : If the history is of some variables are filtered, you can
%               use this input to choose to plot the smoothed or updated
%               estimates of the filtered variables. Either 'smoothed' or
%               'updated'. Default is 'smoothed'.
%
% Output:
%
% - plotter          : An object of class nb_graph. Use the graphSubPlots
%                      method or the nb_graphSubPlotGUI class.
%
% - plotFunction2Use : A string with the name of the method to call on the
%                      plotter object to produce the graphs.
%
% See also:
% nb_model_generic.uncondForecast, nb_model_generic.forecast
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4 
        increment = 1;
        if nargin < 3
            startDate = '';
            if nargin < 2
                type = 'default';
            end
        end
    end
    
    types            = {'smoothed','updated'};
    default          = {'type',  'smoothed', @(x)nb_ismemberi(x,types)};...
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    obj = obj(:);
    
    % Check for nowcast
    nobj    = size(obj,1);
    nowcast = zeros(1,nobj);
    try
        for ii = 1:nobj
            if isfield(obj(ii).forecastOutput,'nowcast')
                nowcast(ii) = obj(ii).forecastOutput.nowcast;
            end
        end
    catch %#ok<CTCH>
        error([mfilename ':: Forecast for the model ' int2str(ii) ' is not found.'])
    end
    if any(nowcast > 0)
        type = [type,'_nowcast'];
    end
    
    % Produce graphs
    switch lower(type)
        
        case 'default'
            [plotter,plotFunction2Use] = defaultMethod(obj,startDate,inputs);
        case 'default_nowcast'
            [plotter,plotFunction2Use] = defaultNowcastMethod(obj,startDate,nowcast,inputs);
        case {'hairyplot','hairyplot_nowcast'}
            [plotter,plotFunction2Use] = hairyplotMethod(obj,increment);
        otherwise
            
            error([mfilename ':: Unsupported plot type ' type])
            
    end

end

%==========================================================================
function [plotter,plotFunction2Use] = defaultMethod(obj,startDate,inputs)

    % Get the all the unique variables of different models
    nobj      = size(obj,1);
    vars      = cell(1,nobj);
    nSteps    = nan(1,nobj);
    startFcst = cell(1,nobj);
    freq      = nan(1,nobj);
    try
        for ii = 1:nobj
            vars{ii}      = obj(ii).forecastOutput.variables;
            nSteps(ii)    = obj(ii).forecastOutput.nSteps;
            startFcst{ii} = obj(ii).forecastOutput.start{end};
            [~,freq(ii)]  = nb_date.date2freq(startFcst{ii});
        end
    catch %#ok<CTCH>
        error([mfilename ':: Forecast for the model ' int2str(ii) ' is not found.'])
    end

    freq = unique(freq);
    if numel(freq) ~= 1
        error([mfilename ':: The forecast from the different models must have the same frequency.'])
    end
    
    if isempty(startDate)
        startFcst = unique(startFcst);
        if numel(startFcst) ~= 1
            error([mfilename ':: The models must start their last forecast at the same date if the start date is not provided.'])
        end
        startFcst    = startFcst{1};
        startFcstObj = nb_date.toDate(startFcst,freq);
    else

        if ischar(startDate)
            startFcst    = startDate;
            startFcstObj = nb_date.toDate(startDate,freq); 
        else
            startFcstObj = startDate;
            startFcst    = toString(startDate);
        end

        indSD = nan(1,nobj);
        for ii = 1:nobj
            indSDT = find(strcmpi(startDate,obj(ii).forecastOutput.start),1);
            if isempty(indSDT)
                error([mfilename ':: Forecast for the model ' int2str(ii) ' is not found for the date ' startDate '.'])
            end
            indSD(ii) = indSDT;
        end

    end
    allVars = unique(nb_nestedCell2Cell(vars));
    allVars = nb_ts.getDiff(allVars,{'Constant','Time-trend'});
    nVars   = length(allVars);
    mSteps  = max(nSteps);

    % Get the mean forecast of all the models
    meanData = nan(mSteps,nVars,nobj);
    for ii = 1:nobj

        indS       = 1:nSteps(ii);
        [ind,indV] = ismember(allVars,vars{ii});
        indV       = indV(ind);
        if isempty(startDate)
            meanData(indS,ind,ii) = obj(ii).forecastOutput.data(:,indV,end,end);
        else
            meanData(indS,ind,ii) = obj(ii).forecastOutput.data(:,indV,end,indSD(ii));
        end

    end

    % Get history of all the forecasted variables
    if isa(obj,'nb_mfvar')
        
        % If all model are mixed frequency VARs we add each history as
        % its own page.
        histData = nb_ts();
        for ii = 1:nobj
            try
                data = getHistory(obj(ii),vars{ii},startDate,false,inputs.type);
            catch %#ok<CTCH>
                break
            end
            histData = addPages(histData,data);
        end
        
    else
        histData = nb_ts;
        cont     = 1;
        ii       = 1;
        while cont

            try
                data = getHistory(obj(ii),vars{ii},startDate,false,inputs.type);
            catch %#ok<CTCH>
                break
            end
            try
                histData = merge(histData,data);
            catch Err
                error([mfilename ':: It seems to me that the estimation data are conflicting for some of the variable. Error: ' Err.message])
            end
            cont = ~all(ismember(allVars,histData.variables));                
            ii   = ii + 1;

        end
    end
    
    % Create data with fcst
    data = nb_ts(meanData,'mean',startFcst,allVars);
    if isempty(histData)
        warning([mfilename ':: Could not load historical data.'])
    else
        % Merge with history
        if histData.endDate > (startFcstObj - 1)
            histData = window(histData,'',startFcstObj-1);
        end
        data = merge(histData,data);
    end
    data.dataNames = getModelNames(obj);

    % Create graph object
    plotter = nb_graph_ts(data);
    plotter.set('dashedLine',toString(startFcstObj-1));
    if isa(obj,'nb_mfvar')
        misVars    = data.variables;
        actualVars = regexprep(misVars,'^AUX_','');
        actualData = getHistory(obj(1),unique(actualVars),'',true);
        for ii = 1:length(misVars)
            subOptions.(misVars{ii}).dashedLine = toString(getRealEndDate(actualData(actualVars{ii})));
        end
        plotter.set('subPlotsOptions',subOptions);
    end
    
    % Get the density forecast of the first model if it is produced
    if obj(1).forecastOutput.draws ~= 1 || obj(1).forecastOutput.parameterDraws ~= 1


        perc = obj(1).forecastOutput.perc;
        if isempty(perc)
            perc = 1:size(obj(1).forecastOutput.data,3) - 1;
            perc = strtrim(cellstr(num2str(perc')))';
        else
            perc = strtrim(cellstr(num2str(perc')))';
        end
        if isempty(startDate)
            fcstData = obj(1).forecastOutput.data(:,:,1:end-1,end);
        else
            fcstData = obj(1).forecastOutput.data(:,:,1:end-1,indSD(1));
        end
        nPerc                = size(fcstData,3);
        density              = zeros(mSteps+1,nVars,nPerc);
        indS                 = 2:nSteps(1)+1;
        [ind,indVV]          = ismember(allVars,histData.variables);
        indVV                = indVV(ind);
        density(1,ind,:)     = repmat(histData.data(end,indVV),[1,1,nPerc]); 
        [ind,indV]           = ismember(allVars,vars{1});
        indV                 = indV(ind);
        density(indS,ind,:)  = fcstData(:,indV,:);
        density              = nb_ts(density,'',startFcstObj-1,allVars);
        density.dataNames    = perc;
        if isempty(obj(1).forecastOutput.perc)
            plotter.set('fanDatasets',density);
        else
            plotter.set('fanDatasets',density,'fanPercentiles',...
                nb_interpretPerc(obj(1).forecastOutput.perc,true));
        end

    end  

    plotFunction2Use = 'graphSubPlots';

end

%==========================================================================
function [plotter,plotFunction2Use] = defaultNowcastMethod(obj,startDate,nowcast,inputs)

    % Get the all the unique variables of different models
    nobj   = size(obj,1);
    vars   = cell(1,nobj);
    nSteps = nan(1,nobj);
    freq   = nan(1,nobj);
    try
        for ii = 1:nobj
            vars{ii}     = obj(ii).forecastOutput.variables;
            nSteps(ii)   = obj(ii).forecastOutput.nSteps;
            [~,freq(ii)] = nb_date.date2freq(obj(ii).forecastOutput.start{1});
        end
    catch %#ok<CTCH>
        error([mfilename ':: Forecast for the model ' int2str(ii) ' is not found.'])
    end
    
    freq = unique(freq);
    if numel(freq) ~= 1
        error([mfilename ':: The forecast from the different models must have the same frequency.'])
    end
    
    allVars = unique(nb_nestedCell2Cell(vars));
    %allVars = nb_ts.getDiff(allVars,{'Constant','Time-trend'});
    nVars   = length(allVars);
    maxNow  = max(nowcast);
    mSteps  = max(nSteps) + maxNow; % Include nowcast
    
    % Get startDate
    if isempty(startDate)
        indFirst     = find(nowcast,1);
        startDate    = obj(indFirst).forecastOutput.start{end};
    end
    startDate    = toString(startDate);
    startDateObj = nb_date.toDate(startDate,freq);
    
    % Which variables are nowcasted?
    nowcasted = find(nowcast);
    missing   = zeros(1,nVars);
    for ii = nowcasted
        missingInd   = any(obj(ii).forecastOutput.missing,1);
        missingT     = vars{ii}(missingInd);
        [ind,loc]    = ismember(missingT,allVars);
        loc          = loc(ind);
        missing(loc) = sum(obj(ii).forecastOutput.missing(:,missingInd),1);
    end
    
    % Get the mean forecast of all the models
    meanData = nan(mSteps,nVars,nobj);
    for ii = 1:nobj

        varsT = vars{ii};
        for vv = 1:length(varsT)
        
            varT = varsT{vv};
            indA = find(strcmpi(varT,allVars),1);
            if isempty(indA)
                continue
            end
            mis = missing(indA);
            if mis > 0 && nowcast(ii) == 0
                % This model does not use later information on other 
                % variables as is the case for the other models, so we
                % lag it some periods.
                indSD = find(strcmpi(toString(startDateObj - mis),obj(ii).forecastOutput.start),1);
                if isempty(indSD)
                    error([mfilename ':: Forecast for the model ' int2str(ii) ' is not found for the date ' toString(startDateObj - mis) '.'])
                end
            else
                indSD = find(strcmpi(toString(startDateObj),obj(ii).forecastOutput.start),1);
                if isempty(indSD)
                    error([mfilename ':: Forecast for the model ' int2str(ii) ' is not found for the date ' startDate '.'])
                end
            end
                
            if mis > 0 && nowcast(ii) == 0
                % We have went some period back to fetch the forecast, 
                % that why we start from period 1
                indG = 1:nSteps(ii);
                indS = indG;
            elseif maxNow > nowcast(ii) 
                indG = 1:nSteps(ii)+nowcast(ii);
                indS = (maxNow - nowcast(ii)) + indG;
            elseif maxNow == nowcast(ii)
                indS = 1:nSteps(ii)+nowcast(ii);
                indG = indS;
            end
            
            % Get the forecast from the given model
            meanData(indS,indA,ii) = obj(ii).forecastOutput.data(indG,vv,end,indSD);
            
        end

    end
    
    % Get history of all the forecasted variables
    histData = nb_ts;
    cont     = 1;
    ii       = 1;
    while cont
        try
            data = getHistory(obj(ii),vars{ii},startDate,false,inputs.type);
        catch %#ok<CTCH>
            break
        end
        try
            histData = append(histData,data);
        catch Err
            error([mfilename ':: It seems to me that the estimation data are conflicting for some of the variable. Error: ' Err.message])
        end
        cont = ~all(ismember(allVars,histData.variables));                
        ii   = ii + 1;
    end
   
    % Create data with fcst and merge with history
    dNames = getModelNames(obj);
    data   = nb_ts(meanData,'mean',startDateObj-maxNow,allVars);
    if isempty(histData)
        warning([mfilename ':: Could not load historical data.'])
    else
        histData = window(histData,'',startDateObj-1);
        data      = append(data,histData); % Observations in data overwrites those of histData
    end
    data.dataNames = dNames;

    % Create graph object
    plotter    = nb_graph_ts(data);
    subOptions = struct();
    misVars    = allVars(missing>0);
    miss       = missing(missing>0);
    for ii = 1:length(misVars)
        subOptions.(strrep(misVars{ii},'.','_')).dashedLine = toString(startDateObj - miss(ii) - 1);
    end
    plotter.set('dashedLine',toString(startDateObj-1),'subPlotsOptions',subOptions);
    
    % Get the density forecast of the first model if it is produced
    if obj(1).forecastOutput.draws ~= 1 || obj(1).forecastOutput.parameterDraws ~= 1

        perc = obj(1).forecastOutput.perc;
        if isempty(perc)
            perc = 1:size(obj(1).forecastOutput.data,3) - 1;
            perc = strtrim(cellstr(num2str(perc')))';
        else
            perc = strtrim(cellstr(num2str(perc')))';
        end
        if isempty(startDate)
            fcstData = obj(1).forecastOutput.data(:,:,1:end-1,end);
        else
            fcstData = obj(1).forecastOutput.data(:,:,1:end-1,indSD(1));
        end
        nPerc                = size(fcstData,3);
        density              = zeros(mSteps+1+nowcast(1),nVars,nPerc);
        indS                 = 2:nSteps(1)+1+nowcast(1);
        [ind,indVV]          = ismember(allVars,histData.variables);
        indVV                = indVV(ind);
        density(1,ind,:)     = repmat(histData.data(end-nowcast(1),indVV),[1,1,nPerc]); 
        [ind,indV]           = ismember(allVars,vars{1});
        indV                 = indV(ind);
        density(indS,ind,:)  = fcstData(:,indV,:);
        density              = nb_ts(density,'',startDateObj-(1+nowcast(1)),allVars);
        density.dataNames    = perc;
        if isempty(obj(1).forecastOutput.perc)
            plotPerc = [0.3,0.5,0.7,0.9];
        else
            plotPerc = nb_interpretPerc(obj(1).forecastOutput.perc,true); 
        end
        plotter.set('fanDatasets',density,'fanPercentiles',plotPerc);

    end  

    plotFunction2Use = 'graphSubPlots';

end

%==========================================================================
function [plotter,plotFunction2Use] = hairyplotMethod(obj,increment)

    if numel(obj) ~= 1
        error([mfilename ':: The type ''hairyplot'' is only supported for a scalar nb_model_generic object.'])
    end

    % Get the actual data as a nb_ts object
    nowcast = obj.forecastOutput.nowcast;
    if nowcast
        maxM = max(sum(obj.forecastOutput.missing));
    else
        maxM = 0;
    end
    
    dep      = obj.forecastOutput.variables;
    ind      = ismember(dep,obj.forecastOutput.dependent);
    dep      = dep(ind); % Only plot the dependent variables
    start    = obj.forecastOutput.start;
    [~,freq] = nb_date.date2freq(obj.forecastOutput.start(1));
    if isa(obj,'nb_midas')
        objT       = obj;
        objT       = objT.setEstOptions(obj.estOptions(end)); % Get final revision if dealing with real-time data
        dataActual = getHistory(objT,dep);
    else
        dataActual = getHistory(obj,dep,'',true);
    end
    dataActual.dataNames = {'Actual'};
    orderedVars          = dataActual.variables;

    % Are we dealing with real-time
    real_time_estim = false;
    if isprop(obj,'options')
        if isfield(obj.options,'real_time_estim')
            real_time_estim = obj.options.real_time_estim;
        end 
    end
    
    % Get mean/median fcst at each period 
    data     = nb_ts;
    fcstData = permute(obj.forecastOutput.data(:,:,end,:),[1,2,4,3]);
    vars     = obj.forecastOutput.variables;
    nPeriods = size(fcstData,3);
    for ii = 1:increment:nPeriods

        startFcstM1 = nb_date.toDate(start{ii},freq) - (1 + maxM);
        fcstPeriod  = fcstData(:,:,ii);
        if real_time_estim % Real-time
            try
                if isa(obj,'nb_midas')
                    eInd     = obj.estOptions(ii).end_low;
                    [~,indY] = ismember(orderedVars,obj.estOptions(ii).dataVariables);
                    actual   = obj.estOptions(ii).data(eInd,indY);
                elseif isa(obj,'nb_model_selection_group')
                    eInd     = obj.models{1}.estOptions(ii).estim_end_ind - maxM;
                    [~,indY] = ismember(orderedVars,obj.models{1}.estOptions(ii).dataVariables);
                    actual   = obj.models{1}.estOptions(ii).data(eInd,indY);
                else
                    eInd     = obj.estOptions(ii).estim_end_ind - maxM;
                    [~,indY] = ismember(orderedVars,obj.estOptions(ii).dataVariables);
                    actual   = obj.estOptions(ii).data(eInd,indY);
                end
            catch
                actual = nan(0,size(fcstPeriod,2));
            end
        else
            if ~isempty(dataActual)
                if startFcstM1 > dataActual.endDate || startFcstM1 < dataActual.startDate
                    actual = nan(0,size(fcstPeriod,2));
                else
                    actual = double(dataActual.window(startFcstM1,startFcstM1));
                end
            else
                actual      = nan(0,size(fcstPeriod,2));
                orderedVars = vars;
            end
        end
        [~,indV]    = ismember(orderedVars,vars);
        fcstPeriod  = [actual;fcstPeriod(:,indV)];
        fcstPeriod  = nb_ts(fcstPeriod,start{ii},startFcstM1,orderedVars);
        data        = addPages(data,fcstPeriod);

    end

    data = addPages(data,dataActual);
    if nowcast
        depM = dep(any(obj.forecastOutput.missing(:,ind),1));
        for ii = 1:length(depM)
            data = rename(data,'variable',depM{ii},[depM{ii},' (Including nowcasts)']);
        end
    end
    plotter = nb_graph_ts(data);
    plotter.set('subPlotSize',[1,1],'lineWidths',{'Actual',4},'noLegend',1,...
                'colors',{'Actual','black'},'missingValues','interpolate');

    plotFunction2Use = 'graphSubPlots';

end

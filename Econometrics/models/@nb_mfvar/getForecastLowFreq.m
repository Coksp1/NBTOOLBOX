function [fcstData,fcstDates,fcstPercData] = getForecastLowFreq(obj,freq,outputType,includeHist,variables)
% Syntax:
%
% [fcstData,fcstDates]              = getForecastLowFreq(obj,freq)
% [fcstData,fcstDates,fcstPercData] = getForecastLowFreq(obj,freq,...
%                                       outputType)
% [fcstData,fcstDates,fcstPercData] = getForecastLowFreq(obj,freq,...
%                                       outputType,includeHist,variables)
%
% Description:
%
% Get the forecast at a low frequency as a nb_ts object.
%
% Caution : In the case that low frequency variables are observed with
%           one or more periods of data at a given recursion, these 
%           variables will be given nan for the number of extra periods of
%           data for the given recursion.
%
% Input:
% 
% - obj          : An object of class nb_mfvar. Must have produced 
%                  forecast.
% 
% - freq         : The returned frequency of the forecast. Only the
%                  variables observed at this frequency are returned.
%
% - outputType   : 
%
%    > 'recursive' : The fcstData output is a nb_ts with size nHor x nVars  
%                    x nPeriods. nPeriods is the number of iterative 
%                    forecast. The start date of each forecast will be  
%                    saved in the dataNames property of the nb_ts object. 
%
%                    The fcstPercData output is a struct where the fields
%                    are the percentiles/simulations of the density  
%                    forecast if produced. (Else it is a empty struct).   
%                    Each field has the same sizes as the fcstData output.
%
%    > 'date'      : A string or a nb_date object with the date of the
%                    wanted forecast. E.g. '2012Q1'. The fcstData will 
%                    be a nb_ts object with size nHor x nVar x nPerc + 1, 
%                    while fcstPercData will be empty. nPerc will then be 
%                    the number of percentiles/simualtions. Mean will be  
%                    at last page.
%
% - includeHist  : Give true (1) to include smmothed estimates of the 
%                  history in the output. Only an options for the 'date'
%                  outputType. Default is false (0).
%
% - variables    : The variables to get the forecast of, as a cellstr.
%                  When this is given the original frequency of the
%                  variables are disregarded 
%
% Output:
% 
% - fcstData     : See the input outputType 
%
% - fcstDates    : The forecast dates for each variable, in the case that 
%                  if the outputType is a date. Otherwise the start date
%                  of the forecast of all the variable for the given
%                  recursion.
%                  
% - fcstPercData : See the input outputType 
%
% See also:
% nb_model_generic.plotForecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 5
        variables = {};
        if nargin < 4
            includeHist = 0;
            if nargin < 3
                outputType = '';
            end
        end
    end
    
    if numel(obj) > 1
        error([mfilename ':: The obj input must be a scalar nb_mfvar object.'])
    end
    if ~isforecasted(obj)
        error([mfilename ':: The model is not forecasted.'])
    end

    dateInput = true;
    if isempty(outputType) 
        outputType = obj.forecastOutput.start{end};
    else
        try 
            date = nb_date.toDate(outputType,obj.options.data.frequency);
        catch
            date = [];
        end
        if isempty(date)
            dateInput = false;
        end
    end
    
    if isempty(variables)
        variables = [obj.dependent.name,obj.block_exogenous.name];
    end
    if dateInput
        
        [fcstData,fcstDates,fcstPercData,failed] = getForecastAtDate(obj,variables,outputType,freq,nargout > 2,includeHist);
        if failed == 1
            warning('nb_mfvar:getForecastLowFreq',['No forecast at the freq ' nb_date.getFrequencyAsString(freq)...
                    ' produced by this model.'])
        elseif failed == 2
            warning('nb_mfvar:getForecastLowFreq',['Cannot get the forecast at the highest frequency, i.e. ' nb_date.getFrequencyAsString(freq)...
                    '. Use getForecast/plotForecast instead.'])
        end
        
    else
        
        if strcmpi(outputType,'recursive')
            [fcstData,fcstDates,fcstPercData] = getForecastDefault(obj,variables,freq,nargout > 2);
        else
            error([mfilename ':: Unsupported outputType ' outputType ' selected.'])
        end
        
    end
    

end

%==========================================================================
function [fcstData,fcstDates,fcstPercData,failed] = getForecastAtDate(obj,vars,date,freq,doDensity,includeHist)

    % Get the frequencies of the variables
    freqOfVars = getFrequency(obj,date);
    
    % Keep only the variables that is originally on the wanted frequency
    indVar   = freq == freqOfVars;

    indS = strcmpi(toString(date),obj.forecastOutput.start);
    if ~any(indS)
        error([mfilename ':: Could not locate the forecast at the date ' toString(date)])
    end
    indS = find(indS,1,'last');
    
    % Do any variable has this frequency?
    failed = false;
    if ~any(indVar) 
        fcstData     = nb_ts();
        fcstDates    = {};
        fcstPercData = nb_ts();
        failed       = 1;
        return
%     elseif freq == max(freqOfVars)
%         fcstData     = nb_ts();
%         fcstDates    = {};
%         fcstPercData = nb_ts();
%         failed       = 2;
%         return
    end
    
    % Get history
    dateObj     = nb_date.toDate(date,obj.options.data.frequency);
    vars        = vars(indVar);
    histData    = getHistory(obj,vars,date,true);
    histData    = window(histData,'',dateObj-1);
    histData    = convert(histData,freq,'discrete');
    missing     = isnan(double(histData));
    numVars     = histData.numberOfVariables;
    mPeriods    = zeros(1,numVars);
    smoothed    = getHistory(obj,vars,indS);
    smoothed    = window(smoothed,'',dateObj-1);
    
    % Get number of missing at low frequency
    startLow      = convert(smoothed.startDate,freq);
    endLow        = histData.endDate;
    numPeriodsLow = (endLow - startLow) + 1;
    for ii = 1:numVars
        mPeriods(ii) = numPeriodsLow - find(~missing(:,ii),1,'last');
    end
    
    % Get forecast one high frequency data
    [~,indV]  = ismember(vars,obj.forecastOutput.variables);
    if iscell(obj.forecastOutput.data)
        fcstData = obj.forecastOutput.data{indS}(:,indV,end); % Mean
    else
        fcstData = obj.forecastOutput.data(:,indV,end,indS); % Mean
    end
    fcstData  = nb_ts(fcstData,'Mean',obj.forecastOutput.start{indS},vars);
    fcstData  = append(smoothed,fcstData);
    fcstData  = convert(fcstData,freq,'discrete');
    
    % Get the forecast dates of each variable
    fcstDate  = endLow + 1;
    fcstDates = fcstDate(:,ones(1,numVars));
    for ii = 1:numVars
        fcstDates(ii) = fcstDates(ii) - mPeriods(ii);
    end
    
    % Density forecast
    if size(obj.forecastOutput.data,3) > 1 && doDensity
        
        perc = obj(1).forecastOutput.perc;
        if isempty(perc)
            perc = 1:size(obj.forecastOutput.data,3) - 1;
            perc = strtrim(cellstr(num2str(perc')))';
        else
            perc = strtrim(cellstr(num2str(perc')))';
        end
        fcstPercData           = obj(1).forecastOutput.data(:,indV,1:end-1,end);
        fcstPercData           = nb_ts(fcstPercData,'',obj.forecastOutput.start{indS},vars);
        fcstPercData.dataNames = perc;
        fcstPercData           = append(smoothed,fcstPercData);
        fcstPercData           = convert(fcstPercData,freq,'discrete');
        
    else
        fcstPercData = nb_ts;
    end
    
    if ~includeHist
        fcstDate = min(fcstDates);
        fcstData = window(fcstData,fcstDate);
        for ii = 1:numVars
            if fcstDates(ii) > fcstDate
                fcstData = setToNaN(fcstData,fcstData.startDate,fcstDates(ii) - 1,vars{ii});
            end
        end
        if ~isempty(fcstPercData)
            fcstPercData = window(fcstPercData,fcstDate);
            for ii = 1:numVars
                if fcstDates(ii) > fcstDate
                    fcstPercData = setToNaN(fcstPercData,fcstPercData.startDate,fcstDates(ii) - 1,vars{ii});
                end
            end
        end
    end
    
end

%==========================================================================
function [fcstData,fcstDates,fcstPercData] = getForecastDefault(obj,vars,freq,doDensity)

    if doDensity
        error([mfilename ':: It is not yet possible to get density forecast recursivly.'])
    end
      
    % Keep only the variables that is originally on the wanted frequency
    freqVars = [obj.dependent.name,obj.block_exogenous.name];
    if all(ismember(vars,freqVars))
        
        % Get the frequencies of the variables
        freqOfVars = getFrequency(obj);
        
        % In this case we return only the variables having this frequency
        % originally
        indVar = freq == freqOfVars;
        vars   = vars(indVar);
        
    end
    
    % Get the smoothed variables index
    [test,sLoc] = ismember(vars,obj.results.smoothed.variables.variables);
    if any(~test) 
        test = ismember(vars(~test),obj.reporting(:,1));
        if any(~test)
            error([mfilename ':: Cannot get the forecast of the variables; ' vars(~test)])
        else
            smoothedRec = getFiltered(obj,'smoothed',false,false,'reporting','stored');
            [~,sLoc]    = ismember(vars,smoothedRec.variables);
            smoothedRec = double(smoothedRec);
        end
    else
        smoothedRec = obj.results.smoothed.variables.data;
    end
    
    % Get the last history
    numVars  = length(vars);
    histData = getHistory(obj,vars,'',true);
    
    % Get index of low in high at longest history
    nSteps       = obj.forecastOutput.nSteps;
    [~,ind]      = histData.startDate.toDates(0:histData.numberOfObservations + nSteps - 1,'default',freq,false); 
    fcstPercData = struct();
    nRec         = length(obj.forecastOutput.start);
    fcstDataC    = cell(1,nRec);
    mPeriodsC    = nan(1,nRec);
    fcstDates    = cell(1,nRec);
    for ii = 1:nRec
        
        % Get history
        startObj = nb_date.toDate(obj.forecastOutput.start{ii},histData.frequency);
        endHist  = startObj - 1;
        if obj.options.real_time_estim
            histDataOne = getHistory(obj,vars,ii,true);
        else
            histDataOne = histData;
        end
        histDataOne  = window(histDataOne,'',endHist);
        histDataOne  = double(histDataOne);
        indLow       = ind(ind <= size(histDataOne,1));
        histDataOneL = histDataOne(indLow,:);
        numHist      = size(histDataOneL,1);
        missing      = isnan(histDataOneL);
        mPeriods     = zeros(1,numVars);
        smoothed     = smoothedRec(:,sLoc,ii);
        smoothed     = smoothed(1:size(histDataOne,1),:);
        
        % Get number of missing at low frequency
        numPeriodsLow = size(histDataOneL,1);
        for jj = 1:numVars
            mPeriods(jj) = numPeriodsLow - find(~missing(:,jj),1,'last');
        end
        mPeriodsC(ii) = max(mPeriods);
        indFcst       = numHist - mPeriodsC(ii) + 1;
        
        % Get forecast one high frequency data
        [~,indV] = ismember(vars,obj.forecastOutput.variables);
        if iscell(obj.forecastOutput.data)
            % Dealing with forecast produced by the nb_model_vintages class
            fcstData = obj.forecastOutput.data{ii}(:,:,end); % Mean
        else
            fcstData = obj.forecastOutput.data(:,indV,end,ii); % Mean
        end
        fcstData = vertcat(smoothed,fcstData); %#ok<AGROW>
        indLow   = ind(indFcst:end);
        indLow   = indLow(indLow <= size(fcstData,1));
        fcstData = fcstData(indLow,:);
        if mPeriodsC(ii) > 0
            for jj = 1:numVars
                % Set already known values to nan
                s                = max(mPeriods) - mPeriodsC(ii);
                fcstData(1:s,jj) = nan;
            end 
        end
        fcstDataC{ii} = fcstData;
        fcstDates{ii} = toString(convert(startObj,freq) - mPeriodsC(ii));
        
    end
    
    % Turn into double
    nHor      = cellfun(@(x)size(x,1),fcstDataC);
    nHorMax   = max(nHor);
    fcstDataD = nan(nHorMax,numVars,nRec);
    for ii = 1:nRec     
        ind                 = 1:nHor(ii);
        fcstDataD(ind,:,ii) = fcstDataC{ii};
    end
    
    % Make nb_data object
    fcstData = nb_data(fcstDataD,obj.forecastOutput.start,1,vars);

end

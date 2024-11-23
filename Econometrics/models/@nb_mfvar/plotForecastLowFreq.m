function [plotter,plotFunction2Use] = plotForecastLowFreq(obj,freq,type,startDate,highPeriod)
% Syntax:
%
% plotter                    = plotForecastLowFreq(obj,freq)
% [plotter,plotFunction2Use] = plotForecastLowFreq(obj,freq,type,...
%                                  startDate,highPeriod)
%
% Description:
%
% Plot forecast. 
%
% Caution density forecast will only be displayed for the first model
% in the vector of nb_model_generic objects
% 
% Input:
% 
% - obj  : A vector of nb_mfvar objects.
%
% - freq : The frequency of the forecast to plot. Only the variables 
%          observed at this frequency are plotted.
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
% - startDate  : A string with the start date of the forecast to plot. As a 
%                string or an object of class nb_date. Only an option when  
%                type is 'default'. Default is to plot the latest forecast
%                produced. Must be at the high frequency.
%
% - highPeriod : Give 0 to get the forecast when the data of low and high 
%                frequency is balanced, 1 if the high frequency data has 
%                one more observation, and so on. Default is 0.   
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
% nb_model_generic.forecast, nb_model_forecast.plotForecast
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 5
        highPeriod = 0;
        if nargin < 4
            startDate = '';
            if nargin < 3
                type = 'default';
            end
        end
    end
    
    obj = obj(:);
    if any(~isforecasted(obj))
        modelNames = getModelNames(obj(~isforecasted(obj)));
        error([mfilename ':: The following model is not forecasted; ' toString(modelNames)])
    end
      
    if strcmpi(type,'default')
        [plotter,plotFunction2Use] = getDefaultPlotter(obj,freq,startDate);
    else
        [plotter,plotFunction2Use] = getHairyPlotter(obj,freq,highPeriod);
    end
    
end

%==========================================================================
function [plotter,plotFunction2Use] = getDefaultPlotter(obj,freq,startDate)

    if isempty(startDate)
        start = obj(1).forecastOutput.start{end};
    end
    
    % Get forecast data
    fcstDates                            = cell(size(obj,1),1);
    vars                                 = cell(size(obj,1),1);
    [fcstData,fcstDates{1},fcstPercData] = getForecastLowFreq(obj(1),freq,start,true);
    vars{1}                              = fcstData.variables;
    for ii = 2:size(obj,1)
        if isempty(startDate)
            start = obj(ii).forecastOutput.start{end};
        end
        [fcstDataOne,fcstDates{ii}] = getForecastLowFreq(obj(ii),freq,start,true);
        vars{ii}                    = fcstDataOne.variables;
        fcstData                    = addPages(fcstData,fcstDataOne);
    end
    
    if isempty(fcstData)
        error([mfilename ':: Nothing to plot. See warnings.'])
    end
    
    % Get unique vars
    allVars     = horzcat(vars{:});
    fcstDates   = horzcat(fcstDates{:});
    [uVars,ind] = unique(allVars);
    fcstDates   = fcstDates(ind);
    
    % Create graph object
    plotter = nb_graph_ts(fcstData);
    for ii = 1:length(uVars)
        subOptions.(uVars{ii}).dashedLine = toString(fcstDates(ii) - 1);
    end
    plotter.set('fanDatasets',fcstPercData,'subPlotsOptions',subOptions);
    plotFunction2Use = 'graphSubPlots';

end

%==========================================================================
function [plotter,plotFunction2Use] = getHairyPlotter(obj,freq,highPeriod)

    if numel(obj) > 1
        error([mfilename ':: Hairyplot is only supported for a scalar object.'])
    end

    % Get recursive forecast
    fcstData = getForecastLowFreq(obj,freq,'recursive');
    startObj = nb_date.toDate(fcstData.dataNames{1},obj.options.data.frequency);
    [~,ind]  = toDates(startObj,0:fcstData.numberOfDatasets-1,'default',freq);
    indEnd   = fcstData.numberOfDatasets;
    ind      = ind + highPeriod - 1;
    ind      = ind(ind <= indEnd & ind > 0);
    fcstData = fcstData(:,:,ind);
    
    % Get Historical data
    histData           = getHistory(obj,fcstData.variables,'',true);
    histData.dataNames = {'Actual'};
    histData           = convert(histData,freq);
    
    % Convert to nb_ts
    start      = startObj + (ind(1) - 1);
    start      = convert(start,freq);
    dates      = start + (0:fcstData.numberOfDatasets-1);
    fcstDataTS = nb_ts();
    for ii = 1:fcstData.numberOfDatasets
        fcstDataTSOne = tonb_ts(fcstData(:,:,ii),dates(ii) + (fcstData(:,:,ii).startObs - 1));
        fcstDataTS    = addPages(fcstDataTS,fcstDataTSOne);
    end
    fcstDataTS.dataNames = fcstData.dataNames;
    
    % Make plotter
    data = addPages(fcstDataTS,histData);
    if highPeriod > 0
        data = addPostfix(data,['(' int2str(highPeriod) ' period(s) more)']);
    end
    plotter = nb_graph_ts(data);
    plotter.set('subPlotSize',[1,1],'lineWidths',{'Actual',4},'noLegend',1,...
                'colors',{'Actual','black'});

    plotFunction2Use = 'graphSubPlots';

end

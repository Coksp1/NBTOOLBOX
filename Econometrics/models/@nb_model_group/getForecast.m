function [fcstData,fcstPercData] = getForecast(obj,outputType,includeHist,varargin)
% Syntax:
%
% fcstData                = getForecast(obj)
% [fcstData,fcstPercData] = getForecast(obj,outputType)
% [fcstData,fcstPercData] = getForecast(obj,outputType,includeHist,varargin)
%
% Description:
%
% Get the forecast output on the nb_ts format object. 
% 
% Input:
% 
% - obj          : An object of class nb_model_group. Must have produced 
%                  forecast.
%
% - outputType   : 
%
%    > 'default'  : The fcstData output is a nb_ts with size nHor x nVars  
%                   x nPeriods. nPeriods is the number of iterative 
%                   forecast. The start date of each forecast will be saved 
%                   in the dataNames property of the nb_ts object. 
%
%                   The fcstPercData output is a struct where the fields
%                   are the percentiles/simulations of the density forcast 
%                   if produced. (Else it is a empty struct). Each field  
%                   has the same sizes as the fcstData output.
%
%    > 'graph'    : This option can be used to make it easier to plot the
%                   recursive densities.
%
%                   The fcstData output is a struct where the fields
%                   are the recursive forecast periods. Each field has size
%                   nHor x nVars x 1. Only storing the mean forecast.
%
%                   The fcstPercData output is a struct where the fields
%                   are the recursive forecast periods. Each field has size
%                   nHor x nVars x nPerc. Storing the 
%                   percentiles/simulations of the forecast if they is  
%                   calculated, or else it is a empty struct.
%
%                   To graph the recursive forecast use this example:
%
%                   fields = fieldnames(fcstData);   
%                   for ii = 1:length(fields)
%
%                       fcstMean = fcstData.(fields{ii});
%                       fcstPerc = fcstPercData.(fields{ii});
%                       plotter  = nb_graph_ts(fcstMean);
%                       plotter.set('fanDatasets',fcstPerc);
%                       plotter.graph();
%
%                   end
%
%      > 'date'   : A string or a nb_date object with the date of the
%                   wanted forecast. E.g. '2012Q1'. The fcstData will 
%                   be a nb_ts object with size nHor x nVar x nPerc + 1, 
%                   while fcstPercData will be empty. nPerc will then be 
%                   the number of percentiles/simualtions. Mean will be at 
%                   last page.
%
%                   For real-time forecast the vintage at the time is
%                   returned as the historical data, when includeHist
%                   is true.
%
% - includeHist : Give true (1) to include history in the output. Only an
%                 options for the 'date' outputType. Default is false (0).
%
% 
% Optional inputs:
%
%    > 'horizon'  : The fcstData output will be a nb_ts object with 
%                   size nRec x nVars. While the fcstPercData output 
%                   will be a nb_ts object with size nRec x nVars x nSim.
%                   You can set the horizon to return by the optional 
%                   input 'horizon'. See the 'timing' option also.
%
% Output:
% 
% - fcstData     : See the input outputType 
%
% - fcstPercData : See the input outputType 
%
% See also:
% nb_model_group.plotForecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        outputType = 'default';
    end
    
    default = {'horizon',       [],         @(x)nb_isScalarInteger(x,0)};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    if isa(outputType,'nb_date')
        outputType = outputType.toString();
    end

    if numel(obj) > 1
        error([mfilename ':: This function is only supported for a single nb_model_group as input'])
    else
        
        if nb_isempty(obj.forecastOutput)
            error([mfilename ':: Noe forecast of this model is produced'])
        end
        
        vars  = obj.forecastOutput.variables;
        start = obj.forecastOutput.start;
        
        switch lower(outputType)
        
            case 'default'
                
                fcst     = obj.forecastOutput.data;
                fcstData = nb_ts(permute(fcst(:,:,end,:),[1,2,4,3]),start,'1',vars);
                
                if nargout > 1
                    
                    fcstPercData = struct();
                    perc         = obj.forecastOutput.perc;
                    if isempty(perc)
                        return
                    end
                    
                    for ii = 1:numel(perc)
                        fcstPercData.(['Perc_' num2str(perc(ii))]) = nb_ts(permute(fcst(:,:,ii,:),[1,2,4,3]),start,'1',vars);
                    end
                    
                end
                
            case 'graph'
                
                fcst     = obj.forecastOutput.data;
                nPeriods = size(fcst,4);
                fcstData = struct();
                for ii = 1:nPeriods
                    fcstData.(['Period_' start{ii}]) = nb_ts(fcst(:,:,end,ii),'Mean','1',vars); 
                end
                
                if nargout > 1
                    
                    fcstPercData = struct();
                    perc         = obj.forecastOutput.perc;
                    if isempty(perc)
                        nSim = size(fcst,3) - 1;
                        if nSim > 0
                            for ii = 1:nPeriods
                                fcstPercData.(['Period_' start{ii}]) = nb_ts(fcst(:,:,1:end-1,ii),start,'1',vars);
                            end
                        end
                        return
                    end
                    
                    for ii = 1:nPeriods
                        fcstPercData.(['Period_' start{ii}]) = nb_ts(permute(fcst(:,:,1:end-1,ii),[1,2,4,3]),start,'1',vars);
                    end
                    
                end
                
            case 'horizon'
                
                if isempty(inputs.horizon)
                
                    vars   = obj.forecastOutput.variables;
                    startD = obj.forecastOutput.start{1};
                    fcst   = permute(obj.forecastOutput.data(:,:,end,:),[4,2,1,3]);
                    nPer   = size(fcst,1);
                    nVar   = size(fcst,2);
                    nHor   = size(fcst,3);
                    try
                        now = obj.forecastOutput.nowcast;
                    catch %#ok<CTCH>
                        now = false;
                    end
                    if now
                        nHor  = nHor + 1;
                    end
                    out = nan(nPer + nHor - 1 + now,nVar,nHor);
                    for ii = 1:nHor
                        out(ii:end - (nHor - ii - now),:,ii) = fcst(:,:,ii);
                    end
                    hors     = strrep(nb_cellstrlag({'horizon'},nHor - now),'_lag','');
                    fcstData = nb_ts(out,hors,startD,vars);
                    if includeHist
                        histData           = getHistory(obj,vars);
                        histData           = window(histData,startD);
                        histData.dataNames = {'Actual'};
                        fcstData           = addPages(fcstData,histData);
                    end
                    fcstPercData = [];  
                    
                else
                    
                    h         = inputs.horizon;
                    fcstDataD = permute(obj.forecastOutput.data(h,:,end,:),[4,2,3,1]);
                    startD    = nb_date.date2freq( obj.forecastOutput.start{1} ) + (inputs.horizon - 1); 
                    fcstData  = nb_ts(fcstDataD,{['horizon' int2str(h)]},startD,obj.forecastOutput.variables);
                    if includeHist
                        histData           = getHistory(obj,obj.forecastOutput.variables);
                        histData           = window(histData,startD);
                        histData.dataNames = {'Actual'};
                        fcstData           = addPages(fcstData,histData);
                    end
                    if nargout > 1
                        fcstPercDataD = permute(obj.forecastOutput.data(h,:,1:end-1,:),[4,2,3,1]);
                        fcstPercData  = nb_ts(fcstPercDataD,'Simulation',startD,obj.forecastOutput.variables);
                    end
                    
                end
                
            otherwise
                
                ind = find(strcmpi(outputType,start),1);
                if isempty(ind)
                    error([mfilename ':: There has not been produced any forecast at the selected date; '  outputType])
                end
                
                fcst = obj.forecastOutput.data(:,:,:,ind);
                perc = obj.forecastOutput.perc;
                if isempty(perc)
                    
                    nSim = size(fcst,3) - 1;
                    if nSim > 0
                        dataNames = cell(1,nSim);
                        for ii = 1:nSim
                            dataNames{ii} = ['Simulation_' int2str(ii)];
                        end
                        dataNames = [dataNames,{'Mean'}];
                    else
                        dataNames = {'Mean'};
                    end
                    
                else
                    if size(fcst,3) > 1
                        dataNames = cell(1,numel(perc));
                        for ii = 1:numel(perc)
                            dataNames{ii} = ['Perc_' num2str(perc(ii))];
                        end
                    else
                        dataNames = {};
                    end
                    dataNames = [dataNames,{'Mean'}];
                end
                
                fcst         = permute(fcst,[1,2,3]);
                fcstData     = nb_ts(fcst,dataNames,outputType,vars);
                fcstPercData = nb_ts();
                
                % Get history of all the forecasted variables
                if includeHist
                    
                    histData = getHistory(obj,vars,outputType);
                    histData = window(histData,'',fcstData.startDate-1);
                    try
                        fcstData = merge(fcstData,histData);
                    catch Err
                        error([mfilename ':: Could not merge the history with the forecast. Error: ' Err.message])
                    end
                end
                
                
        end
        
    end
    
end

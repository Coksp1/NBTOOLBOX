function [pit,plotter,pitTest] = getPIT(obj,startDate,endDate,onlyFinal)
% Syntax:
%
% pit                   = getPIT(obj)
% [pit,plotter]         = getPIT(obj)
% [pit,plotter,pitTest] = getPIT(obj,startDate,endDate,onlyFinal)
%
% Description:
%
% Calculate PIT of a density forecast given actual data. 
%
% Caution : If recursive density forecast has been produced it will
%           get the PIT from the start date of the recursive forecast and
%           use the density forecast at each periods to produce the pits.
%
%           If only one density forecast has been produce it will construct
%           the PITs based on the period from the estimation start date 
%           until the end date of forecast horizon.
%
% Caution : Nowcasts will be skipped!
% 
% Input:
% 
% - obj       : A nb_model_forecast object.
%
% - startDate : The start date of the PIT calculations, as a string or a 
%               nb_date object. Default is as written above.
%
%               Caution : If you do recursive density forecast, this date 
%                         cannot be before the start date of the recursive
%                         forecast (if not onlyFinal is set to true). 
%                         Otherwise the start date cannot be before the
%                         start date of the data stored in the model
%                         object.
%
% - endDate   : The start date of the PIT calculations, as a string or a 
%               nb_date object. Default is to use the last forecast
%               recursion or the date the density is constructed. This
%               input cannot be after that, except when onlyFinal option
%               is set to 1 or only one density is estimated. The end date 
%               can then be set to a date as long you have observations
%               on the actual data. (Stored in options.data)
%
% - onlyFinal : Logical. If true the final density forecast is used to
%               calculate the PITs even if recursive density forecast
%               exists. Default is false. If startDate is empty the start
%               date of estimation will be used as default.
% 
% Output:
% 
% - pit     : A nb_data object with size nPeriods x nHor x nVars
%
% - plotter : A nb_graph_data object. please use the graph method, if you
%             want to plot it.
%
% - pitTest : Test for a uniformily distributed PITs using a Pearson
%             chi-squared test. As a 2 x nHor x nVar nb_cs object.
%
% See also:
% nb_calculatePIT
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        onlyFinal = false;
        if nargin < 3
            endDate = '';
            if nargin < 2
                startDate = '';
            end
        end
    end

    if isa(startDate,'nb_date')
        startDate = toString(startDate);
    end
    
    if isa(endDate,'nb_date')
        endDate = toString(endDate);
    end
    
    if numel(obj) ~= 1
        error([mfilename ':: This function takes only one nb_model_generic object as input. Not a vector!'])
    end

    % Calculate the PIT
    %----------------------------------------------------------------------
    forecastOuput = obj.forecastOutput;
    if nb_isempty(forecastOuput)
        error([mfilename ':: No forecast has been produced by this model.'])
    end
       
    % Get the some forecast output
    nSteps    = forecastOuput.nSteps;
    fcstEval  = forecastOuput.evaluation;
    vars      = forecastOuput.dependent;
    nVars     = length(vars);
    startFcst = forecastOuput.start;
    indD      = ismember(forecastOuput.variables,vars);

    if ~isempty(startDate)
        indS = find(strcmpi(startDate,startFcst),1);
        if isempty(indS)
            error([mfilename ':: The selected startDate is outside the window of the recursive forecast (' startFcst{1} ' - ' startFcst{end} ')'])   
        end
    else
        indS = 1;
    end

    if ~isempty(endDate)
        indE = find(strcmpi(endDate,startFcst),1);
        if isempty(indE)
            error([mfilename ':: The selected endDate is outside the window of the recursive forecast (' startFcst{1} ' - ' startFcst{end} ')'])   
        end
    else
        indE = length(startFcst);
    end
    
    startFcst = startFcst(indS:indE);
    if isempty(startFcst)
       error([mfilename ':: The selected end date is before the selected start date.']) 
    end
    
    if numel(startFcst) == 1 || onlyFinal % Recursive forecast but only the final density should be evaluated
        inSample = true;
    else
        inSample = false;
    end
    
    % Get the actual data to evaluate against
    start    = nb_date.date2freq(startFcst{1});
    finish   = nb_date.date2freq(startFcst{end-1});
    vars     = obj.forecastOutput.dependent;
    histData = getHistory(obj,vars);
    try
        histData = reorder(histData,vars);
    catch %#ok<CTCH>
        error([mfilename ':: Could not get the historical data on all the variables of the model group.'])
    end
    actual = window(histData,start,finish);
    actual = [actual.data;nan(1,size(actual.data,2))];
    actual = nb_splitSample(actual,nSteps);
    
    % Get the density and domain
    try
        if forecastOuput.saveToFile || forecastOuput.inputs.saveToFile
            load(fcstEval(1).density)
        else
            density = {fcstEval.density};
            domain  = {fcstEval.int};
        end
    catch %#ok<CTCH>
        error([mfilename ':: Density forecast is not produced for this model!'])
    end
    
    kernelEstDone = true;
    if isempty(density) 
        kernelEstDone = false;
    elseif all(cellfun(@isempty,density))
        kernelEstDone = false;
    end
    
    if ~kernelEstDone
        error([mfilename ':: Kernel density estimation is not produced for this model. ',...
                         'Set the ''estimateDensities'' input to the forecast method to true!'])
    end
    
    % Calculate the PIT
    nowcast = forecastOuput.nowcast;
    if inSample

        fcstData = forecastOuput.data(:,indD,:,:);
        nPeriods = size(actual,3);
        if size(fcstData,4) ~= nPeriods
            error([mfilename ':: You have not done recursive forecast and therefore it is not possible to evaluate those (even with the final density)'])
        end
        if isempty(endDate)
            finalFcst = fcstData(:,:,end,end);
        else
            indED     = find(strcmpi(endDate,forecastOuput.start),1);
            finalFcst = fcstData(:,:,end,indED);
        end
        fcstDiff   = fcstData(:,:,end,indS:indE) - finalFcst(:,:,:,ones(1,nPeriods)); % Difference in the mean forecast from the final forecast
        fcstDiff   = permute(fcstDiff,[1,2,4,3]);
        pitOfModel = nan(nPeriods,nVars,nSteps);
        ll         = 1;
        for jj = indS:indE
            for kk = 1:nVars
                pitTemp             = nb_calculatePIT(density{end}{kk}(nowcast+1:end,:),domain{end}{kk}(nowcast+1:end,:),actual(:,kk,ll),fcstDiff(:,kk,ll));
                pitOfModel(ll,kk,:) = permute(pitTemp,[3,2,1]);
            end
            ll = ll + 1;
        end

    else % Out of sample

        nPeriods   = size(startFcst,2);
        pitOfModel = nan(nPeriods,nVars,nSteps); 
        ll         = 1;
        for jj = indS:indE
            for kk = 1:nVars
                pitTemp             = nb_calculatePIT(density{jj}{kk}(nowcast+1:end,:),domain{jj}{kk}(nowcast+1:end,:),actual(:,kk,ll));
                pitOfModel(ll,kk,:) = permute(pitTemp,[3,2,1]);
            end
            ll = ll + 1;
        end
        
    end
    
    hor = strcat('Horizon',strtrim(cellstr(int2str([1:size(pitOfModel,3)]')))); %#ok<NBRAK>  
    pit = nb_data(permute(pitOfModel,[1,3,2]),vars,1,hor);
    
    % Graph object
    %------------------------------------------------------
    if nargout > 1
        
        histPIT  = histcounts(pit,0.1:0.1:1,0.05:0.1:1);
        plotter  = nb_graph_data(histPIT);
        plotter.set('variablesToPlot',      hor,...
                    'variableToPlotX',      'Interval',...
                    'plotType',             'grouped',...
                    'barWidth',             0.08,...
                    'horizontalLine',       pit.numberOfObservations*0.1,...
                    'horizontalLineWidth',  1.5,...
                    'xLim',                 [0,1]);
                
    end
    
    % PIT-test
    %------------
    if nargout > 2
        
        E        = pit.numberOfObservations*0.1;
        histPIT  = window(histPIT,'','',hor');
        dataTest = histPIT.data;
        dataTest = (dataTest - E).^2./E;
        dataTest = sum(dataTest,1);
        pitTest  = nb_distribution.chis_cdf(dataTest,pit.numberOfObservations-1);
        pitTest  = nb_cs([dataTest;pitTest],vars,{'Pearson chi-squared test','(p-value)'},hor);
        
    end
    
end

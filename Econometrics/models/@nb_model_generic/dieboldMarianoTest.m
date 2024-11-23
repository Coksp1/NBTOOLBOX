function [test,pval,res] = dieboldMarianoTest(obj1,obj2,varargin)
% Syntax:
%
% [test,pval,res] = dieboldMarianoTest(obj1,obj2,varargin)
%
% Description:
%
% Diebold-Mariano test. The null is that the models produce equally good 
% forecast.
% 
% Only the forecast variables from both models are tested! I.e. the 
% intersect.
%
% Caution : The actual data is taken from obj1.
%
% Caution: Testing of nowcasts is not supported, and are skipped!
%
% Input:
% 
% - obj1      : An object of class nb_model_generic. You need to call one 
%               of the forecasting functions first!
% 
% - obj2      : An object of class nb_model_generic. You need to call one 
%               of the forecasting functions first!
% 
% Optional inputs:
%
% - 'startDate'    : The start date of the test, as a string or a nb_date
%                    object. If it is not provided the default is to use
%                    the first date which there exist forecast from the two
%                    models.
%
% - 'endDate'      : The end date of the test, as a string or a nb_date
%                    object. If it is not provided the default is to use
%                    the last date which there exist forecast from the two
%                    models.
%
% - 'precision'    : The precision of the printed result. As a string. 
%                    Default is '%8.6f'. 
%
% - 'bandWidth'    : The selected band width of the frequency zero
%                    spectrum estimation. Default is to use a automatic
%                    selection criterion. See the 'bandWithCrit' input.
%                    Must be set to an integer greater then 0.
%
% - 'bandWithCrit' : Band with selection criterion. Either:
%
%                     > 'nw'   : Newey-West selection method. 
%                                Default.
%
%                     > 'a'    : Andrews selection method. AR(1)
%                                specification.
%
% - 'multivariate' : Set to true to do the multivariate test, i.e. test
%                    for equal panel forecast. Default is to test each 
%                    variable separatly. 
%
% Output:
% 
% - test    : A nb_ts object with the test statistic. As a 
%             nHor x nModel x nVar nb_ts object.
%
% - pval    : A nb_ts object with the p-values of the test. As a 
%             nHor x nModel x nVar nb_ts object.
%
% - res     : A char with the printout of the test.
%
% See also:
% nb_model_generic.uncondForecast
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Parse inputs
    if numel(obj1) > 1
        error([mfilename ':: The obj1 input must be a 1x1 nb_model_generic object.'])
    end
    
    if numel(obj2) > 1
        error([mfilename ':: The obj2 input must be a 1x1 nb_model_generic object.'])
    end
    
    default = {'bandWidth',     [],        @(x)nb_isScalarNumber(x,0);...
               'bandWithCrit',  'nw',      @(x)nb_ismemberi(x,{'nw','a'});...
               'multivariate',  false,     @nb_isScalarLogical;...
               'precision',     '%8.6f',   @nb_isOneLineChar;...
               'startDate',     '',        {@nb_isOneLineChar,'||',@(x)isa(x,'nb_date'),'||',@isempty};...
               'endDate',       '',        {@nb_isOneLineChar,'||',@(x)isa(x,'nb_date'),'||',@isempty}};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    bandWidth    = inputs.bandWidth;
    bandWithCrit = inputs.bandWithCrit;
    precision    = inputs.precision;
    
    % Get the forecast and actual data from both models
    forecast1 = obj1.forecastOutput;
    if nb_isempty(forecast1)
        error([mfilename ':: You need to produce forecast of obj1 with on of the forecasting methods before doing this test!'])
    end
    forecast2 = obj2.forecastOutput;
    if nb_isempty(forecast2)
        error([mfilename ':: You need to produce forecast of obj2 with on of the forecasting methods before doing this test!'])
    end
    opt       = obj1.estOptions(end);
    allVars   = intersect(forecast1.dependent, forecast2.dependent);
    nAllVars  = length(allVars);
    allDates  = intersect(forecast1.start, forecast2.start,'stable');
    nDates    = length(allDates);
    minHor    = min(forecast1.nSteps,forecast2.nSteps);
    
    % Check the start/end date option
    startDate = inputs.startDate;
    if ~isempty(startDate)
        
        sDate = nb_date.date2freq(allDates{1});
        indS  = startDate - sDate + 1;
        if indS < 1
            error([mfilename ':: The startDate input is before the combined start date of forecast of the two models.'])
        elseif indS > nDates
            error([mfilename ':: The startDate input is after the combined end date of forecast of the two models.'])
        end
        allDates = allDates(1,indS:end);
        nDates   = length(allDates);
        
    end
    
    endDate = inputs.endDate;
    if ~isempty(endDate)
        
        eDate = nb_date.date2freq(allDates{end});
        indE  = eDate - endDate;
        if indE < 0
            error([mfilename ':: The endDate input is after the combined end date of forecast of the two models.'])
        elseif indE > nDates
            error([mfilename ':: The endDate input is before the combined start date of forecast of the two models.'])
        end
        if indE ~= 0
            allDates = allDates(1,1:end-indE+1);
            nDates   = length(allDates);
        end
        
    end
    
    if nDates < 10
        error([mfilename ':: Too few recursive periods selected to use the Diebold-Mariano test.'])
    end
    
    % Get the actual data
    actual = nb_model_generic.getActual(opt,obj1.solution,allVars,allDates,[]);
    actual = actual(1:end-1,:);
    
    % Get the forecast
    indD1         = ismember(forecast1.start,allDates(1:end-1));
    forecastData1 = forecast1.data(forecast1.nowcast+1:minHor,:,end,indD1); % Get mean/median forecast
    [~,ind]       = ismember(allVars,forecast1.variables);
    forecastData1 = forecastData1(:,ind,:,:);
    forecastData1 = permute(forecastData1,[4,2,1,3]);
    indD2         = ismember(forecast2.start,allDates(1:end-1));
    forecastData2 = forecast2.data(forecast2.nowcast+1:minHor,:,end,indD2); % Get mean/median forecast
    [~,ind]       = ismember(allVars,forecast2.variables);
    forecastData2 = forecastData2(:,ind,:,:);
    forecastData2 = permute(forecastData2,[4,2,1,3]);
    
    % Order things properly
    for hh = 1:minHor
        forecastData1(:,:,hh) = [nan(hh-1,nAllVars);forecastData1(1:end-hh+1,:,hh)]; 
        forecastData2(:,:,hh) = [nan(hh-1,nAllVars);forecastData2(1:end-hh+1,:,hh)]; 
    end
    
    % Do the test
    [testM,pvalM] = nb_dieboldMarianoTest(forecastData1,forecastData2,actual,...
        bandWidth,bandWithCrit,'multivariate',inputs.multivariate);

    % Report the results
    if inputs.multivariate
        allVars  = {'Multivariate'};
        nAllVars = 1;   
    end
    test  = nb_ts(testM,'','1',allVars);
    pval  = nb_ts(pvalM,'','1',allVars);    
    
    if nargout > 2
        
        if isempty(precision)
            precision = '%8.6f';
        else
            if ~ischar(precision)
                error([mfilename ':: The precision input must be of the type %8.6f.'])
            end
            precision(isspace(precision)) = '';
            if ~strncmp(precision(1),'%',1)||~all(isstrprop(precision([2,4]),'digit'))||...
               ~isstrprop(precision(end),'alpha')
                error([mfilename ':: The precision input must be of the type %8.6f.'])
            end
        end
        
        % Print results
        res                  = sprintf('Test: %s','Diebold-Mariano Test');
        res                  = char(res,sprintf('Null hypothesis: %s','The forecasts from the two models are equally good'));
        res                  = char(res,sprintf('%s',['Sample: ' allDates{1} ' - ' allDates{end-1}]));
        res                  = char(res,sprintf('%s',nb_clock('gui')));
        res                  = char(res,'');
        allHor               = 1:minHor;
        allHor               = cellstr(int2str(allHor'));  
        table                = repmat({' '},[1 + minHor*2,1 + nAllVars]);
        table(1,1)           = {'Horizon'};
        table(1,2:end)       = allVars;
        table(2:2:end,2:end) = nb_double2cell(testM,precision);
        table(3:2:end,2:end) = nb_double2cell(pvalM,precision);
        table(2:2:end,1)     = allHor;
        table(3:2:end,1)     = repmat({'(P-Value)'},[minHor,1]);
        tableAsChar          = cell2charTable(table);
        res                  = char(res,tableAsChar);
        res                  = char(res,'');
        
    end
    
end

function [obj,x,outputfile,errorfile,model] = x12Census(obj,varargin)
% Syntax:
%
% obj = x12Census(obj)
% [obj,x,outputfile,errorfile,model] = x12Census(obj)
% [obj,x,outputfile,errorfile,model] = x12Census(obj,varargin)
%
% Description:
%
% Do x12 Census adjustement to an nb_ts object using x12awin.exe.
%
% This is a file copied from the IRIS Toolbox an adapted to the
% NB Toolbox. (I.e. using nb_ts instead of tseries)
%
% x12awin.exe is a program developed by: 
%
% U. S. Department of Commerce, U. S. Census Bureau
%
% X-12-ARIMA quarterly seasonal adjustment Method,
% Release Version 0.3  Build 192
% 
% This method modifies the X-11 variant of Census Method II
% by J. Shiskin A.H. Young and J.C. Musgrave of February, 1967.
% and the X-11-ARIMA program based on the methodological research
% developed by Estela Bee Dagum, Chief of the Seasonal Adjustment
% and Time Series Staff of Statistics Canada, September, 1979.
% 
% This version of X-12-ARIMA includes an automatic ARIMA model
% selection procedure based largely on the procedure of Gomez and
% Maravall (1998) as implemented in TRAMO (1996). 
% 
% Caution : The object must be of quarterly or monhtly frequency!!
%
% Input:
% 
% - obj   : Input data that will seasonally adjusted or filtered
%           by the Census X12 Arima. Must be an nb_ts object.
%
% Optional input (...,'propertyName',propertyValue,...):
% 
% - 'backcast'  : Run a backcast based on the fitted ARIMA model  
%                 for this number of periods back to improve on the 
%                 seasonal adjustment. The backcast is included
%                 in the output argument x. Must be a scalar. 
%
% - 'log'       : Logarithmise the input data before, and  
%                 de-logarithmise the output data back after, 
%                 running x12. {1} | 0
%
% - 'forecast'  : Run a forecast based on the fitted ARIMA model 
%                 for this  number of periods ahead to improve on 
%                 the seasonal adjustment. The forecast is included
%                 in the output argument x. Must be a scalar.
%
% - 'display'   : Display X12 output messages in command window. 
%                 {0} | 1. Default is not.
%
% - 'dummy'     : Dummy variable or variables (in case of a  
%                 multivariate nb_ts object) used in X12-ARIMA 
%                 regression; the dummy variables can also include  
%                 values for forecasts and backcasts if you request 
%                 them. Either an nb_ts object or empty.
%
% - 'dummyType' : Type of dummy. Either 'ao' | {'holiday'} | 'td'
% 
% - 'mode'      : Seasonal adjustment mode. 'auto' means that 
%                 series with only positive or only negative  
%                 numbers will be adjusted in the 'mult' 
%                 (multiplicative) mode, while series with combined 
%                 positive and negative numbers in the 'add' 
%                 (additive) mode.  {'auto'} | 'add' | 'logadd' | 
%                 'mult' | 'pseudoadd' | 'sign'
% 
% - 'maxIter'   : Maximum number of iterations for the X12 
%                 estimation procedure. Must be numeric. Default is 
%                 1500.
% 
% - 'maxOrder'  : A 1-by-2 vector with maximum order for the  
%                 regular ARMA model (can be 1, 2, 3, or 4) and  
%                 maximum order for the seasonal ARMA model (can be 
%                 1 or 2). Must be numeric. Default is [1,2].
% 
% - 'missing'   : Allow for in-sample missing observations, and  
%                 fill in values predicted by an estimated ARIMA 
%                 process; if false, the seasonal adjustment will  
%                 not run and a warning will be thrown. 1 | {0}.
% 
% - 'output'    : Requested output data, as a string. Either:
%
%                 - 'irregular'     : For the irregular component, 
%
%                 - 'seasadj'       : For the final seasonally 
%                                     adjusted series. Default.
%
%                 - 'seasonal'      : For seasonal factors. 
%
%                 - 'trendcycle'    : For the trend-cycle.
%
%                 - 'missingvaladj' : For the original series with   
%                                     missing observations replaced 
%                                     with ARIMA estimates.
% 
% - 'specFile'  : Name of the X12-ARIMA spec file Must be a char. 
%                 Default is 'default'.         
% 
% - 'tdays'     : Correct for the number of trading days. 1 | {0}
% 
% - 'tolerance' : Convergence tolerance for the X12 estimation 
%                 procedure.  Must be numeric. Default is 1e-5.
%
% - 'startDate' : Start date of seasonally adjustment.
%
% - 'endDate'   : End date of seasonally adjustment.
% 
% Output:
% 
% - obj        : An nb_ts object with the seasonally/trend 
%                adjusted/component of all the stored series of the
%                object.
%
% - x          : The original object with the backcast and forecast
%                appended. 
%
%                Caution : If the object is link to a data source
%                          this object will still not be 
%                          updateable.
%
% - outputfile : A cellstr array with the output files from 
%                the seasonal/trend adjustment.
% 
% - errorfile  : A cellstr array with error files from the
%                the seasonal/trend adjustment.
%
% - mdl        : A struct with ARIMA model estimates. 
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if obj.numberOfDatasets > 1
        error([mfilename ':: This method does not support multi-paged nb_ts objects.'])
    end

    % Parse the inputs
    %--------------------------------------------------------------
    options = default();
    options = parseOptions(options,varargin{:});
    output  = regexp(options.output,'[a-zA-Z]\d\d','match');
    noutput = length(output);
    data    = double(obj);
    dummy   = double(options.dummy);

    if ~isempty(dummy)
        if size(data,2) == size(dummy,2)
            error([mfilename ':: The nb_ts object given to the ''dummy'' input must has as many variables as the first input.'])
        end
    end
    
    if options.log
        data = log(data);
    end
    
    % Index
    %------------------
    startDate = obj.startDate;
    start     = 1;
    finish    = size(data,1);
    if ~isempty(options.startDate)
        start = (options.startDate - obj.startDate) + 1;
        startDate = options.startDate;
    end
    if ~isempty(options.endDate)
        finish = (options.endDate - obj.endDate) + 1;
    end
    data = data(start:finish,:);

    % Do the filter
    %--------------------------------------------------------------
    [data,outData,outputfile,errorfile,model] = nb_x12.x12(data,startDate,dummy,options);

    % Transform back to nb_ts object
    %--------------------------------------------------------------
    if options.log
        outData = exp(outData);
    end
    obj.data(start:finish,:) = outData;

    % Return original series with forecasts and backcasts.
    %--------------------------------------------------------------
    x = obj;
    if nargout >= noutput+3
        
        % This object is not updateable
        x.links      = struct();
        x.updateable = 0;
        x            = window(x,options.startDate,options.endDate);
        x.startDate  = x.startDate - options.backcast;
        x.endDate    = x.endDate + options.forecast;
        if options.log
            data = exp(data);
        end
        x.data = data;
        
    end
    
    % Add operation
    %--------------------------------------------------------------
    if isUpdateable(obj)

        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = addOperation(obj,@x12Census,varargin);
        
    end
    
end

%==================================================================
% SUB
%==================================================================
function options = default()

    options            = struct();
    options.backcast   = 0;
    options.cleanup    = 1;
    options.dummy      = [];
    options.dummytype  = 'holiday';
    options.display    = 0;
    options.forecast   = 0;
    options.log        = 0;
    options.maxiter    = 1500;
    options.maxorder   = [2,1];
    options.missing    = 0;
    options.mode       = 'auto';
    options.output     = 'd11';
    options.saveas     = '';
    options.specfile   = 'default';
    options.tdays      = 0;
    options.tolerance  = 1e-5;
    options.warning    = 1;
    options.startDate  = '';
    options.endDate    = '';

end

function options = parseOptions(options,varargin)

    for ii = 1:2:length(varargin)

        propertyName  = lower(varargin{ii});
        propertyValue = varargin{ii + 1};
        
        switch propertyName
            
            case 'backcast'
                
                if isnumeric(propertyValue) && isscalar(propertyValue)
                    options.backcast = propertyValue;
                else
                    error([mfilename ':: The input ''' propertyName ''' must be a 1x1 double.'])
                end
                
            case 'log'
                
                if islogical(propertyValue) || propertyValue == 1 || propertyValue == 0
                    options.log = 0;
                else
                    error([mfilename ':: The input ''' propertyName ''' must be a logical.'])
                end
                
            case 'forecast'
                
                if isnumeric(propertyValue) && isscalar(propertyValue)
                    options.forecast = propertyValue;
                else
                    error([mfilename ':: The input ''' propertyName ''' must be a 1x1 double.'])
                end
                
            case 'display'
                
                if islogical(propertyValue) || propertyValue == 1 || propertyValue == 0
                    options.display = propertyValue;
                else
                    error([mfilename ':: The input ''' propertyName ''' must be a logical.'])
                end
                
            case 'dummy'
                
                if isa(propertyValue,'nb_ts')
                    options.dummy = propertyValue;
                else
                    error([mfilename ':: The input ''' propertyName ''' must be an nb_ts object.'])
                end
                
            case 'dummytype'
                
                if any(strcmpi(propertyValue,{'ao','holiday','td'}))
                    options.dummytype  = propertyValue;
                else
                    error([mfilename ':: Invalid value given to the input ''' propertyName '''.'])
                end
                
            case 'mode'
                
                if any(strcmpi(propertyValue,{'auto','add','logadd','mult','pseudoadd','sign'}))
                    options.mode = propertyValue;
                else
                    error([mfilename ':: Invalid value given to the input ''' propertyName '''.'])
                end
                
            case 'maxiter'
                
                if isnumeric(propertyValue) && isscalar(propertyValue)
                    options.maxiter    = propertyValue;
                else
                    error([mfilename ':: The input ''' propertyName ''' must be a 1x1 double.'])
                end
                
            case 'maxorder'
                
                if isnumeric(propertyValue) && size(propertyValue,1) == 1 && size(propertyValue,2) == 2
                    options.maxorder   = propertyValue;
                else
                    error([mfilename ':: The input ''' propertyName ''' must be a 1x2 double.'])
                end
                
            case 'missing'
                
                if islogical(propertyValue) || propertyValue == 1 || propertyValue == 0
                    options.missing = propertyValue;
                else
                    error([mfilename ':: The input ''' propertyName ''' must be a logical.'])
                end
                
            case 'output'
                
                if ischar(propertyValue)
                    options.output = interpretOutputInput(propertyValue);
                else
                    error([mfilename ':: The input ''' propertyName ''' must be a string.'])
                end
                
            case 'specfile'
                
                if ischar(propertyValue)
                    options.specfile = propertyValue;
                else
                    error([mfilename ':: The input ''' propertyName ''' must be a string.'])
                end
                
            case 'tdays'
                
                if islogical(propertyValue) || propertyValue == 1 || propertyValue == 0
                    options.tdays      = propertyValue;
                else
                    error([mfilename ':: The input ''' propertyName ''' must be a logical.'])
                end
                
            case 'tolerance'
                
                if isnumeric(propertyValue) && isscalar(propertyValue)
                    options.tolerance  = propertyValue;
                else
                    error([mfilename ':: The input ''' propertyName ''' must be a 1x1 double.'])
                end
                
            case 'warning'
                
                if islogical(propertyValue) || propertyValue == 1 || propertyValue == 0
                    options.warning = propertyValue;  
                else
                    error([mfilename ':: The input ''' propertyName ''' must be a logical.'])
                end

            case 'startdate'

                if ischar(propertyValue) 
                    options.startDate = nb_date.date2freq(propertyValue); 
                elseif isa(propertyValue,'nb_date')
                    options.startDate = propertyValue; 
                else
                    error([mfilename ':: The input ''' propertyName ''' must be a char or a nb_date object.'])
                end

            case 'enddate'

                if ischar(propertyValue) 
                    options.endDate = nb_date.date2freq(propertyValue); 
                elseif isa(propertyValue,'nb_date')
                    options.endDate = propertyValue; 
                else
                    error([mfilename ':: The input ''' propertyName ''' must be a char or a nb_date object.'])
                end
                
            otherwise
                error([mfilename ':: Unsupported input ' propertyName '.'])
        end
        
    end
    
end

function propertyValue = interpretOutputInput(propertyValue)

    switch lower(propertyValue)
        
        case 'seasonal'
            propertyValue = 'd10';
        case 'seasadj'
            propertyValue = 'd11';
        case 'trendcycle'
            propertyValue = 'd12';
        case 'irregular'
            propertyValue = 'd13';
        case 'missingvaladj'
            propertyValue = 'mv';
        otherwise
            error([mfilename ':: Unsupported value for the input ''output'' provided. (' propertyValue ').'])
    end

end

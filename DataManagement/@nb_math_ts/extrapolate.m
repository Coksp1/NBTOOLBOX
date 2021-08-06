function obj = extrapolate(obj,toDate,varargin)
% Syntax:
%
% obj = extrapolate(obj,toDate)
% obj = extrapolate(obj,toDate,varargin)
%
% Description:
%
% Extrapolate the time-series.
%
% Input:
% 
% - obj          : An object of class nb_math_ts
% 
% - toDate       : Extrapolate to the given date. If the date is before the
%                  end date of the given variable no changes will be made,
%                  and with no warning. Can also be a integer with the
%                  number of periods to extrapolate.
%
% Optional inputs:
%
% - 'alpha'      : Significance level of ADF test for 'flow' or 'stock'.
%
% - 'constant'   : Give true to to include constant in the AR models used 
%                  to extrapolate the individual series. Default is true.
%
% - 'freq'       : The low frequency to fulfill the period for. E.g. if 
%                  the object end at '2000M2', then '2000M3' is 
%                  extrapolated so that all months of the 1st quarter of
%                  2000 have values. toDate must be set to 'low'. Default
%                  is 1.
%
% - 'method'     : 
%
%        > 'end'   : Extrapolate series by using the last observation of 
%                    each series. I.e. a random walk forecast. Default.
%
%        > 'ar'    : Extrapolate each series individually using a fitted
%                    AR model.
%
% - 'takeLog'    : Take log before stock variables are extrapolated in
%                  first difference. true or false.
%
% - 'type'       : 'stock', 'flow' or 'test'. Default is 'flow'. 
%                  'stock' will extrapolate in (log) first difference. 
%                  'test' will use a ADF test to check if the variables 
%                  are stationary ('flow') or not ('stock').
%
% Output:
% 
% - obj          : An nb_math_ts object with extrapolate series.
% 
% Examples:
%
% obj = nb_math_ts.rand('2000M1',50,2,1);
% obj = extrapolate(obj,'2004M3');
% obj = extrapolate(obj,'2004M3','method','ar');
% obj = extrapolate(obj,'low','method','ar','freq',4);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    if isempty(obj)
        error([mfilename ':: Object is empty, and no extrapolation can be done.'])
    end
    types   = {'flow','stock','test'};
    default = {'alpha',     0.05,   @(x)nb_isScalarNumber(x,0);...
               'constant',  false,  @nb_isScalarLogical;...
               'draws',     1000,   @(x)nb_isScalarInteger(x,0);...
               'freq',         1,   @(x)nb_isScalarInteger(x,0);...
               'method',    'end',  @nb_isOneLineChar;...   
               'nLags',     5,      @(x)nb_isScalarInteger(x,0);...
               'takeLog',   false,  @nb_isScalarLogical;...
               'type',      'flow', @(x)nb_ismemberi(x,types)};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    % Interpret the toDate input
    if isempty(toDate)
        error([mfilename ':: toDate cannot be empty.'])
    else
        if nb_isScalarInteger(toDate)
            nPeriods = round(toDate);
            toDate   = obj.endDate + nPeriods;
        elseif nb_isOneLineChar(toDate)
            if strcmpi(toDate,'low')
                if inputs.freq > obj.startDate.frequency
                    error([mfilename ':: The ''freq'' input must be a frequency that is lower than the object itself.'])
                end
                endDateLow = convert(getRealEndDate(obj,'nb_date'),inputs.freq);
                toDate     = convert(endDateLow,obj.startDate.frequency,false);
            else
                toDate = nb_date.toDate(toDate,obj.startDate.frequency);
            end
        elseif isa(toDate,'nb_date')
            if toDate.frequency ~= obj.frequency
                error([mfilename ':: The toDate input must be of the same frequency as the object itself.'])
            end
        end
    end
    
    % Take log?
    if inputs.takeLog
        obj = log(obj);
    end
    
    % Are ww dealing with a stock?
    if strcmpi(inputs.type,'stock')
        init = obj.data(1,:,:);
        obj  = diff(obj,1);
    elseif strcmpi(inputs.type,'test')
        if obj.dim2 > 1
            error([mfilename ':: The number of variables must be equal 1, if ''type'' is set to ''test''.'])
        end
        tested = obj(:,:,end); % Using only last page
        test   = nb_adf(nb_ts(tested));
        if test.rhoPValue > inputs.alpha
            % Cannot reject the null of a unit root, so we take it as
            % a stock
            inputs.type = 'stock';
            init        = obj.data(1,:,:);
            obj         = diff(obj,1);
        end
    end
    
    % Choose extrapolate method
    switch lower(inputs.method)
        case 'ar'
            obj = arExtrapolate(obj,toDate,inputs);
        case 'end'
            obj = endExtrapolate(obj,toDate);
        otherwise
            error([mfilename ':: The method ' inputs.method ' is not supported.'])
    end
    
    if strcmpi(inputs.type,'stock')
        obj = undiff(obj,init,1);
    end
    if inputs.takeLog
        obj = exp(obj);
    end
    
end

%==========================================================================
% SUB
%==========================================================================
function obj = endExtrapolate(obj,toDate)
  
    % Find the number of extrapolating period for the object as a whole
    periods     = max(0,toDate - obj.endDate);
    obj.data    = [obj.data; nan(periods,obj.dim2,obj.dim3)];
    obj.endDate = obj.endDate + periods;

    % Extrapolate the wanted variables
    for vv = 1:obj.dim2
        for pp = 1:obj.dim3
            dataVar = obj.data(:,vv,pp);
            varEnd  = find(~isnan(dataVar),1,'last');
            if isempty(varEnd)
                % The series have only nan values.
                continue
            end
            endDateVar = obj.startDate + (varEnd - 1);
            nSteps     = toDate - endDateVar;
            if nSteps > 0
                obj.data(varEnd+1:varEnd+nSteps,vv,:) = repmat(obj.data(varEnd,vv,pp),[nSteps,1,1]);    
            end
        end
    end

end

%==========================================================================
function obj = arExtrapolate(obj,toDate,inputs)

    % Find the number of extrapolating period for the object as a whole
    periods = max(0,toDate - obj.endDate);
    
    % Preallocate data
    dataOut                 = nan(obj.dim1 + periods, obj.dim2, obj.dim3);
    dataOut(1:obj.dim1,:,:) = obj.data;
    
    % Find the balanced dataset for each variable
    for vv = 1:obj.dim2
        
        for pp = 1:obj.dim3
        
            dataVar  = obj.data(:,vv,pp);
            varStart = find(~isnan(dataVar),1);
            if isempty(varStart)
                % The series have only nan values.
                continue
            end
            varEnd = find(~isnan(dataVar),1,'last');

            % Get individual variable setting 
            endDateVar = obj.startDate + (varEnd - 1);
            data       = dataVar(varStart:varEnd);
            nSteps     = toDate - endDateVar;
            if nSteps > 0
                
                % Estimate and forecast model
                dataLag = lag(data,1);
                beta    = nb_ols(data(2:end),dataLag(2:end),true);
                fcst    = nan(nSteps+1,1);
                fcst(1) = data(end);
                for hh = 1:nSteps
                    fcst(hh+1) = beta(1) + beta(2)*fcst(hh);
                end
                
                % Assign forecast + history back to output
                dataOut(varEnd+1:varEnd + nSteps, vv, pp) = fcst(2:end);

            end
            
        end
        
    end

    % Extrapolate the wanted variable
    obj.data    = dataOut;
    obj.endDate = obj.endDate + periods;

end

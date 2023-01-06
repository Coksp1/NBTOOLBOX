function out = recursiveExtrapolate(obj,variables,nSteps,startDate,varargin)
% Syntax:
%
% out = recursiveExtrapolate(obj,variables,nSteps,startDate)
% out = recursiveExtrapolate(obj,variables,nSteps,startDate,varargin)
%
% Description:
%
% Recursivly extrapolate last of observation of variables with the wanted 
% number of periods.
% 
% Caution: This method only works on a single paged nb_ts object or objects
%          that return true using the isRealTime method.
%
% Input:
% 
% - obj          : An object of class nb_ts
% 
% - variable     : A string with the name of the variable to extrapolate, 
%                  or a cellstr of the variables to extrapolate. Default
%                  is to extrapolate all variables. 
%
%                  Caution: When 'method' is set to copula only the
%                           selected variables are included in the 
%                           calculation of the extrapolated values.
% 
% - nSteps       : Must be an integer with the number of periods
%                  to extrapolate.
%
% - startDate    : Start date of recursive extrapolation. Either as a
%                  a char or an object of which is of a subclass of the
%                  nb_date class. This option is only used when the
%                  dataset is not real-time.
%   
%                  Caution : If all other then the 'end' option is used for
%                            the 'method' option. This options must allow
%                            for a proper number of degrees of fredom for
%                            estimating the model to use to extrapolate.
%
% Optional inputs:
%
% - 'method'     : 
%
%       > 'end'     : Extrapolate series by using the last observation of 
%                     each series. I.e. a random walk forecast.
%
%       > 'copula'  : This approach tries to estimate the unconditional
%                     marginal distribution of each series in the dataset 
%                     and the (auto)correlation structure that discribe
%                     the connection between these series. Some series may
%                     have more observations than others!  
%
%                     Caution : This method works when the unconditional
%                               distribution from which the series are
%                               assumed to be drawn from are the same
%                               over time. E.g. the series must have the
%                               same volatility over the period. The second
%                               assumetion is that all the series are 
%                               stationary. Use the 'check' input to test 
%                               for non-stationarity by a ADF test for 
%                               unit-root. If it is found to have a unit
%                               root the series will be differenced when
%                               forecasted, and then transformed back to
%                               level after that step.
%
%        > 'ar'     : Extrapolate each series individually using a fitted
%                     AR model.
%
%        > 'var'    : Extrapolate all series using a fitted VAR model. Max
%                    number of variables is set to 10 for this option.
%
%        > 'actual' : Extrapolate with actual data. This will lead to 
%                     nans for the last periods!
%
% - 'alpha'      : Significance level of ADF test for stationary series.
%                  Only an option for the 'copula' method.
%
% - 'check'      : Check for stationary series. If not found to be
%                  stationary the series will be differenced and
%                  extrapolated with this transformation before transformed
%                  back to its old level. Only an option for the 'copula' 
%                  method.
%
% - 'nLags'      : Number of lags to include when calculating the
%                  correlation matrix used by the copula. I.e. the number
%                  of historical observations to condition on when forming
%                  the conditional correlation matrix.
%
% - 'draws'      : The number of draws used to estimate the mean, when
%                  using the 'copula' method.
%
% - 'constant'   : Give true to to include constant in the AR models used 
%                  to extrapolate the individual series. Default is false.
%
% Output:
% 
% - out          : A nb_ts object with the recursivly extrapolated series.
% 
% Examples:
%
% obj = nb_ts.rand('1900',50,2,1);
% obj = recursiveExtrapolate(obj,'Var1',4,'1900');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    method         = nb_parseOneOptional('method','',varargin{:});
    isupdateable   = obj.isUpdateable();
    obj.updateable = 0;
    if isRealTime(obj)
        
        if strcmpi(method,'actual')
            error([mfilename ':: Cannot extrapolate with ''actual'' if the data is real-time.'])
        end
        out = nb_ts;
        for p = 1:obj.numberOfDatasets
            objT = window(obj,'','',{},p);
            objT = window(objT,'',obj.getRealEndDate);
            objT = extrapolate(objT,variables,nSteps,varargin{:});
            out  = addPages(out,objT);
        end
        
    else
        
        if obj.numberOfDatasets > 1
            error([mfilename ':: The obj input can only have one page.'])
        end
        if isempty(startDate)
            error([mfilename ':: the startDate input cannot be empty if not dealing with real-time data.'])
        end
        if ischar(startDate)
            startDate = nb_date.date2freq(startDate);
        end
        
        if strcmpi(method,'actual')
            
            objStartD = obj.startDate;
            start     = startDate - objStartD + 1;
            out       = nb_ts;
            numObs    = obj.numberOfObservations;
            for p = start:numObs
                
                if p + nSteps > numObs
                    objT = expandPeriods(obj,p + nSteps - numObs,'nan');
                    out  = addPages(out,objT);
                else
                    objT = window(obj,'',objStartD + (p + nSteps - 1));
                    out  = addPages(out,objT);
                end

            end
            
        else
        
            objStartD = obj.startDate;
            start     = startDate - objStartD + 1;
            out       = nb_ts;
            for p = start:obj.numberOfObservations
                objT = window(obj,'',objStartD + (p - 1));
                objT = extrapolate(objT,variables,nSteps,varargin{:});
                out  = addPages(out,objT);
            end
            
        end
        
    end
    
    obj.updateable = isupdateable;
    if obj.isUpdateable()
        obj   = obj.addOperation(@recursiveExtrapolate,[{variables,nSteps,startDate},varargin]);
        links = obj.links;
        out   = out.setLinks(links);
    end

end


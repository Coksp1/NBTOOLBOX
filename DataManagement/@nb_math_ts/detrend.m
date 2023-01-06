function [obj,trendObj] = detrend(obj,method,output,varargin)
% Syntax:
%
% obj            = detrend(obj,method)
% obj            = detrend(obj,method,output,varargin)
% [obj,trendObj] = detrend(obj,method,output,varargin)
%
% Description:
%
% Detrending nb_ts object.
% 
% Input:
% 
% - obj      : As a nb_math_ts object.
% 
% - method   : Either {'linear'}, 'linear1s', 'mean', 'hpfilter', 
%              'hpfilter1s', 'bkfilter', 'bkfilter1s', 'baiPerron' or
%              'exponentialsmoother'.
%
% - output   : If given as 'trend' the first output will be the
%              trend output instead. 'Normal' is default.
%
% - varargin : Additional inputs. When:
%
%   > 'exponentialsmoother'      : One more input must be given. I.e. 
%                                  weight on previous value. See exptrend
%                                  function for more.
%
%   > 'hpfilter' or 'hpfilter1s' : One more input must be given. I.e. 
%                                  lambda.
%
%   > 'bkfilter' or 'bkfilter1s' : Two more inputs must be given. I.e. 
%                                  lowFreq and highFreq.
%
%   > 'baiPerron'                : Two input may be given:
%                                             
%      The first:
%      * 'bic'   : Bayesian information criterion is used to select the 
%                  breaks. Default.
%      * 'lwz'   : The Liu, Wu and Zidek information criterion is used to 
%                  select the breaks.
%      * integer : An integer with the number of breaks to identify.
% 
%      The second:
%      * integer : The maximum number of breaks to allow when using a
%                  information criterion to choose the number of breaks.
%                  Default is 2.
%
% Output:
% 
% - obj      : As a nb_math_ts object with the detrended data.
%
% - trendObj : As a nb_math_ts object with the trend.
%
% Examples:
% 
% obj = nb_math_ts.rand('2012Q1',10,3);
% obj = detrend(obj,'linear');
% obj = detrend(obj,'hpfilter','',1600);
% obj = detrend(obj,'bkfilter','',6,32);
%
% See also:
% createShift
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        output = 'normal';
        if nargin < 2
            method = 'linear';
        end
    end
    
    trendObj = obj;
    switch lower(method)
        
        case 'bkfilter'
            
            if length(varargin) ~= 2
                error([mfilename ':: When method is ''bkfilter'' two additional inputs must be given to this method. '...
                                 'I.e. the lowFreq and highFreq inputs.'])
            end
            
            gap           = nb_bkfilter(obj.data,varargin{:});
            obj.data      = gap;
            trendObj.data = trendObj.data - gap;
            
        case 'bkfilter1s'
            
            if length(varargin) ~= 2
                error([mfilename ':: When method is ''bkfilter1s'' two additional inputs must be given to this method. '...
                                 'I.e. the lowFreq and highFreq inputs.'])
            end
            
            gap           = nb_bkfilter1s(obj.data,varargin{:});
            obj.data      = gap;
            trendObj.data = trendObj.data - gap;
        
        case 'exponentialsmoother'
            
            if length(varargin) ~= 1
                error([mfilename ':: When method is ''exponentialSmoother'' one additional input must be given to this method. I.e. the weight input.'])
            end
            
            trend         = lag(exptrend(obj.data,varargin{:}));
            obj.data      = obj.data - trend;
            trendObj.data = trend;
            
        case 'hpfilter'
            
            if length(varargin) ~= 1
                error([mfilename ':: When method is ''hpfilter'' one additional input must be given to this method. I.e. the lambda.'])
            end
            
            gap           = hpfilter(obj.data,varargin{:});
            obj.data      = gap;
            trendObj.data = trendObj.data - gap;
            
        case 'hpfilter1s'
            
            if length(varargin) ~= 1
                error([mfilename ':: When method is ''hpfilter1s'' one additional input must be given to this method. I.e. the lambda.'])
            end
            
            gap           = hpfilter1s(obj.data,varargin{:});
            obj.data      = gap;
            trendObj.data = trendObj.data - gap;
            
        case 'linear'
    
            gap           = nb_linearFilter(obj.data);
            obj.data      = gap;
            trendObj.data = trendObj.data - gap;
            
        case 'linear1s'
            
            gap           = nb_linearFilter1s(obj.data);
            obj.data      = gap;
            trendObj.data = trendObj.data - gap;
            
        case 'mean'
            
            mData         = repmat(mean(obj.data,1),[obj.numberOfObservations,1,1]);
            obj.data      = obj.data - mData;
            trendObj.data = mData;
            
        case 'baiperron'
            
            if obj.numberOfDatasets > 1
                error([mfilename ':: The Bai-Perron detrending option is not supported for multi-paged datasets'])
            end
            
            if nargin > 3
                criterion = varargin{1};
            else
                criterion = 'bic';
            end
            
            if nargin > 4
                maxNumBreaks = varargin{2};
            else
                maxNumBreaks = 2;
            end
            
            test  = nb_baiPerronTestStatistic(obj,...
                        'constant',     true,...
                        'criterion',    criterion,...
                        'maxNumBreaks', maxNumBreaks);
            vars  = obj.variables;
            tData = obj.data; 
            for ii = 1:obj.numberOfVariables
                set(test,'dependent',vars{ii});
                doTest(test);
                if test.results.selectedBreak == 0
                    tData(:,ii) = mean(obj.data(:,ii));
                else
                    tData(:,ii) = test.results.estTrend(:,test.results.selectedBreak);
                end
            end
            obj.data      = obj.data - tData;
            trendObj.data = tData;
            
        otherwise
            
            error([mfilename ':: Unsupported detrending method ' method '.'])
            
    end
    
    if strcmpi(output,'trend')
        obj = trendObj;
    end
    
end

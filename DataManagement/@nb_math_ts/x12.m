function varargout = x12(obj,range,varargin)
% Syntax:
%
% varargout = x12(obj,range,varargin)
%
% Description:
%
% Seasonally adjust data of an nb_math_ts object, with the use of 
% the x12 method of the tseries class provided by the IRIS package.
% 
% To use this function you need to add the IRIS package to the 
% MATLAB path.
% 
% Input:
% 
% - obj   : Input data that will seasonally adjusted or filtered
%           by the Census X12 Arima. Must be an nb_math_ts object.
% 
% - range : Date range on which the X12 will be run; if not 
%           specified or Inf the entire available range will be 
%           used. Must be numeric.
%
% Optional input (...,'propertyName',propertyValue,...):
% 
% - 'backcast'  : Run a backcast based on the fitted ARIMA model  
%                 for this number of periods back to improve on the 
%                 seasonal adjustment; see help on the `x11` specs  
%                 in the X12-ARIMA manual. The backcast is included
%                 in the output argument obj. Must be a scalar. 
% 
% - 'cleanup'   : Delete temporary X12 files when done; the 
%                 temporary files are named iris_x12a.*. {'true'} 
%                 | 'false'
%
% - 'log'       : Logarithmise the input data before, and  
%                 de-logarithmise the output data back after, 
%                 running x12. {'true'} | 'false'
%
% - 'forecast'  : Run a forecast based on the fitted ARIMA model 
%                 for this  number of periods ahead to improve on 
%                 the seasonal adjustment; see help on the x11  
%                 specs in the X12-ARIMA manual. The forecast is 
%                 included in the output argument obj. Must be a 
%                 scalar.
%
% - 'display'   : Display X12 output messages in command window; if 
%                 false the  messages will be saved in a TXT file. 
%                 {'true'} | 'false'
%
% - 'dummy'     : Dummy variable or variables (in case of a  
%                 multivariate tseries object) used in X12-ARIMA 
%                 regression; the dummy variables can also include  
%                 values for forecasts and backcasts if you request 
%                 them. Either an tseries or empty.
%
% - 'dummyType' : Type of dummy; see the X12-ARIMA IRIS 
%                 documentation. Either 'ao' | {'holiday'} | 'td'
% 
% - 'mode'      : Seasonal adjustment mode (see help on the x11 
%                 specs in the IRIS X12-ARIMA manual); 'auto' means 
%                 that series with only positive or only negative  
%                 numbers will be adjusted in the 'mult' 
%                 (multiplicative) mode, while series with combined 
%                 positive and negative numbers in the 'add' 
%                 (additive) mode.  {'auto'} | 'add' | 'logadd' | 
%                 'mult' | 'pseudoadd' | 'sign'
% 
% - 'maxIter'   : Maximum number of iterations for the X12 
%                 estimation procedure. See help on the estimation 
%                 specs in the IRIS X12-ARIMA manual. Must be 
%                 umeric. Default is 1500.
% 
% - 'maxOrder'  : A 1-by-2 vector with maximum order for the  
%                 regular ARMA model (can be 1, 2, 3, or 4) and  
%                 maximum order for the seasonal ARMA model (can be 
%                 1 or 2). See help on the automdl specs in the 
%                 IRIS X12-ARIMA manual. Must be numeric. Default 
%                 is [1,2].
% 
% - 'missing'   : Allow for in-sample missing observations, and  
%                 fill in values predicted by an estimated ARIMA 
%                 process; if false, the seasonal adjustment will  
%                 not run and a warning will be thrown. 'true' | 
%                 {'false'}
% 
% - 'output'    : List of requested output data; the cellstr or 
%                 comma-separated list can combine 'IR' for the
%                 irregular component, 'seasadj' for the final 
%                 seasonally adjusted series, 'SF' for seasonal  
%                 factors, 'trendcycle' for the trend-cycle, and 
%                 'MV' for the original series with missing  
%                 observations replaced with ARIMA estimates. See 
%                 also help on the x11 specs in the IRIS X12-ARIMA 
%                 manual. char | cellstr | {'seasadj'} ]
% 
% - 'specFile'  : Name of the X12-ARIMA spec file; if 'default' the 
%                 IRIS default spec file will be used, see 
%                 description. Must be a char. Default is 'default'
%                 
% 
% - 'tdays'     : Correct for the number of trading days. See help 
%                 on the x11regression specs in the IRIS X12-ARIMA 
%                 manual. 'true' | {'false'}
% 
% - 'tolerance' : Convergence tolerance for the X12 estimation 
%                 procedure. See help on the estimation specs in  
%                 the IRIS X12-ARIMA manual. Must be numeric. 
%                 Default is 1e-5.
%
% Output:
% 
% See the IRIS X12-ARIMA manual. Same outputs as the x12 
% method of the tseries class. The only difference is that 
% the tseries outputs are instead nb_math_ts objects.
%   
% Examples:
% 
% [obj,~,err]   = x12(obj,inf,'output','seasadj');
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Transform to a tseries object and use the method x12 of that
    % class. (The IRIS package is needed)
    %--------------------------------------------------------------
    tseries_DB             = toTseries(obj);
    [varargout{1:nargout}] = x12(tseries_DB,range,varargin{:});

    % Transform all the tseries objects to nb_math_ts objects
    %--------------------------------------------------------------
    for ii = 1:nargout

        if isa(varargout{ii},'tseries')

            varargout{ii}  = nb_math_ts(varargout{ii});

        end

    end

end

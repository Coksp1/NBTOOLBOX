function obj = convert(obj,freq,method,varargin)
% Syntax:
%
% obj = convert(obj,freq,method,varargin)
%
% Description:
% 
% Convert the frequency of the data of the nb_math_ts object
% 
% Input:
% 
% - obj    : An object of class nb_math_ts
% 
% - freq   : The new freqency of the data. As an integer:
% 
%            > 1   : yearly
%            > 2   : semi annually
%            > 4   : quarterly
%            > 12  : monthly
%            > 52  : weekly
%            > 365 : daily
% 
% - method : The method to use. Either:
% 
%            From a high frequency to a low:
% 
%            > 'average'     : Takes averages over the subperiods
%            > 'diffAverage' : Uses a weighted average, so that the
%                              diff operators can be converted
%                              correctly. E.g. when converting from monthly
%                              to quarterly, and the level of the variable
%                              of interest is aggregated to quarterly data
%                              using averages, but you want to convert
%                              monthly data on diff to quarterly. The 
%                              formula used is:
%                              diff_Y(q) = 1/3*diff_Y(m) + 2/3*diff_Y(m-1)  
%                                        + diff_Y(m-2) + 2/3*diff_Y(m-3) 
%                                        + 1/3*diff_Y(m-4)
%            > 'diffSum'     : Same as 'diffAverage', but now the
%                              aggregation in levels are done using a sum
%                              instead.
%            > 'discrete'    : Takes last observation in each 
%                              subperiod (Default)
%            > 'first'       : Takes first observation in each 
%                              subperiod 
%            > 'max'         : Takes maximal value over the subperiods
%            > 'min'         : Takes minimum value over the subperiods
%            > 'sum'         : Takes sums over the subperiods        
% 
%            From a low frequency to a high:
% 
%            > 'linear'   : Linear interpolation
%            > 'cubic'    : Shape-preserving piecewise cubic 
%                           interpolation 
%            > 'spline'   : Piecewise cubic spline interpolation  
%            > 'none'     : No interpolation. All data in between 
%                           is given by nans (missing values) 
%                           (Default)
%            > 'fill'     : No interpolation. All periods of the 
%                           higher frequency get the same value as
%                           that of the lower frequency.
%            > 'daverage' : Uses the Denton 1971 method using that
%                           the average of the intra low frequency
%                           periods should preserve the average.
%            > 'dsum'     : Uses the Denton 1971 method using that
%                           the sum of the intra low frequency
%                           periods should preserve the sum.
% 
%            Caution: This input must be given if you provide some 
%                     of the optional inputs.
%          
%            Caution: All these option will by default use the 
%                     first period of the subperiods as base for 
%                     the conversion. Provide the optional input
%                     'interpolateDate' if you want to set the base
%                     to the end periods instead ('end').        
% 
% Optional input:
% 
% - 'includeLast' : Give this string as input if you want to 
%                   include the last period, even if it is not 
%                   finished. Only when converting to lower 
%                   frequencies
% 
%                   E.g: obj = obj.convert(1,'average',...
%                   'includeLast');
% 
% - 'rename'      : Changes the postfixes of the variables names.
% 
%                   E.g. If you covert from the frequency 12 to 4 
%                        the prefixes of the variable names changes 
%                        from 'MUA' to 'QUA', if the prefix exist.
% 
%                   E.g: obj = obj.convert('yearly','average',...
%                                          'rename');
% 
% 
% Optional input (...,'inputName',inputValue,...):
% 
% - 'interpolateDate' : The input after this input must either be
%                       'start' or 'end'.
% 
%                       Date of interpolation. Where 'start' means 
%                       to interpolate the start date of the 
%                       periods of the old frequency, while 'end' 
%                       uses the end date of the periods.
% 
%                       Default is 'start'.
% 
%                       Caution : Only when converting to higher
%                                 frequency.
%
%                       Caution : For weekly data, the 'dayOfWeek' options
%                                 is added. See nb_ts.setDayOfWeek for more
%                                 on this.
% 
%                       E.g: obj = obj.convert(365,'linear',...
%                       'interpolateDate','end');
% 
% Output:
% 
% - obj : An nb_math_ts object converted to wanted frequency.
% 
% Examples:
% 
% obj = obj.convert(4,'average'); 
% obj = obj.convert(365,'linear','interpolateDate','end');
% obj = obj.convert(1,'average','includeLast');  
% obj = obj.convert(1,'average','rename');
%
% Written by Kenneth S. Paulsen                                   

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        method = '';
    end

    vars   = nb_appendIndexes('Var',1:obj.dim2);
    obj_ts = nb_ts(obj,'','',vars);
    obj_ts = convert(obj_ts,freq,method,varargin{:});
    obj    = nb_math_ts(obj_ts);

end

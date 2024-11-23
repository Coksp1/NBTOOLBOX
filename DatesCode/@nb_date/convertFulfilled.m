function obj = convertFulfilled(obj,frequency,first) 
% Syntax:
%
% obj = convertFulfilled(obj,frequency) 
%
% Description:
%
% Convert a date to the wanted frequency. When converting to low frequency
% this method will convert 2012M2 to 2011Q4 and 2012M3 to 2012Q1, i.e.
% the high frequency period must fulfill all the sub periods of the low 
% frequency to be converted to the "current" low period. 
%
% Input:
% 
% - obj       : An object of class nb_day
%
% - frequency : The frequency to convert to. As a scalar.
% 
% - first     : 1 : first period
%               0 : last period
% 
%               Only when converting the object to a higher 
%               frequency. Default is 1. 
%
% Output:
% 
% - obj       : An object of subclass of the nb_date class with the
%               frequency given by the frequency input.
%
% Examples:
%
% obj = nb_month(1,2012);
% obj = obj.convertFulfilled(4);
%
% See also:
% nb_day.convert, nb_week.convert, nb_month.convert, nb_quarter.convert,
% nb_year.convert
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        first = 1;
    end

    if frequency == obj.frequency
        return
    elseif frequency < obj.frequency
        low       = obj.convert(frequency);
        highInLow = low.convert(obj.frequency,false);
        if (highInLow.eq(obj))
            obj = low;
        else
            obj = low.minus(1);
        end
    else 
        obj = obj.convert(frequency,first);
    end

end

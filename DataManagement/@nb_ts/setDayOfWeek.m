function obj = setDayOfWeek(obj,dayOfWeek)
% Syntax:
% 
% obj = setDayOfWeek(obj,dayOfWeek)
%
% Description:
%
% Set the day the week represents when converted to daily frequency.
% 
% Input:
% 
% - obj       : A nb_ts object representing weekly data.
%
% - dayOfWeek : The day of the week. 1 is sunday, 2 is monday, ..., 
%               7 is saturday.
% 
% Output:
% 
% - obj       : A nb_ts object representing weekly data.
%
% See also:
% nb_ts.convert
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if obj.startDate.frequency ~= 52
        error([mfilename ':: Cannot set the dayOfWeek option if frequency is ' nb_date.getFrequencyAsString(obj.startDate.frequency) '.'])
    end
    if ~nb_isScalarInteger(dayOfWeek,-1,8)
        error([mfilename ':: The dayOfWeek input must be an integer between 1 and 7.'])
    end
    obj.startDate.dayOfWeek = dayOfWeek;
    obj.endDate.dayOfWeek   = dayOfWeek;

end

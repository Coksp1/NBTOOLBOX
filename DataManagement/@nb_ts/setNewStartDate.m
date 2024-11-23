function obj = setNewStartDate(obj,start)
% Syntax:
%
% obj = setNewStartDate(obj,start)
%
% Description:
%
% Set new start date of nb_ts object.
% 
% Input:
% 
% - obj   : An object of class nb_ts.
%
% - start : An object of class nb_date or a date string.
% 
% Output:
% 
% - obj   : An object of class nb_ts with the new start date.
%
% See also:
% nb_ts.lag, nb_ts.lead
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isa(start,'nb_date')
        start = nb_date.toDate(start,obj.startDate.frequency);
    else
        if start.frequency ~= obj.startDate.frequency
            error([mfilename ':: The frequency of the start input must be ' nb_date.getFrequencyAsString(obj.startDate.frequency),...
                             ', but is ' nb_date.getFrequencyAsString(start.frequency) '.'])
        end
    end
    if start == obj.startDate
       return 
    end
    per           = start - obj.startDate;
    obj.startDate = start;
    obj.endDate   = obj.endDate + per;
    
end

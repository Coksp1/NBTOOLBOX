function ret = isPeriod(obj,period)
% Syntax:
%
% ret = isPeriod(obj,period)
%
% Description:
%
% Return true if the obj represent the given period, i.e. if you want 
% to test if a nb_quarter object represent the first period of any year
% you can use isPeriod(obj,1).
% 
% Input:
% 
% - obj    : An object which of a subclass of the nb_date class.
% 
% - period : The period to test for.
%
% Output:
% 
% - ret    : True if the object represent the period to test for, else
%            false.
%
% Examples:
%
% q   = nb_quarter(1,2000)
% ret = isPeriod(q,1)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch obj.frequency
        case 1
            ret = obj.year == period;
        case 2
            ret = obj.halfYear == period;
        case 4
            ret = obj.quarter == period;
        case 12
            ret = obj.month == period;
        case 52
            ret = obj.week == period;
        case 365
            ret = obj.day == period;
        otherwise
            error([mfilename ':: Unsupported method for the frequency ' class(obj)])
    end
    
end

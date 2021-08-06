function ret = isFirstPeriod(obj,freq)
% Syntax:
%
% ret = isFirstPeriod(obj,freq)
%
% Description:
%
% Return if the obj represent the first period a lower frequency.
% 
% Input:
% 
% - obj  : An object which of a subclass of the nb_date class.
% 
% - freq : The lower frequency.
%
% Output:
% 
% - ret  : True if the object represent the first period of the lower 
%          frequency.
%
% Examples:
%
% q   = nb_quarter(1,2000)
% ret = isFirstPeriod(q,1)
%
% m   = nb_month(10,2000)
% ret = isFirstPeriod(m,4)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if freq >= obj.frequency
        error([mfilename ':: The freq input must give a lower frequency than that of the object of class ' class(obj) '.'])
    end

    switch obj.frequency
        case 2
            ret = obj.halfYear == 1;
        case 4
            switch freq
                case 1
                    ret = obj.quarter == 1;
                case 2
                    ret = any(obj.quarter == [1,3]);
            end
        case 12
            switch freq
                case 1
                    ret = obj.month == 1;
                case 2
                    ret = any(obj.month == [1,7]);
                case 4
                    ret = any(obj.month == [1,4,7,10]);
            end
        otherwise
            error([mfilename ':: Unsupported method for the frequency ' class(obj)])
    end
    
end

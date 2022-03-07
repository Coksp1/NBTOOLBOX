function obj = convert(obj,frequency,first) 
% Syntax:
%
% obj = convert(obj,frequency,first)
%
% Description:
%
% Convert the nb_month object ot the wanted frequency. The return 
% variable will be an object which is of an subclass of the nb_date
% class.
% 
% Input:
% 
% - obj       : An object of class nb_month
%
% - frequency : The frequency to convert to. As a scalar.
%
% - first     : 1 : first period
%               0 : last period
% 
%               Only when converting the object to a higher 
%               frequency.   
%
% Output:
% 
% - obj       : An object of subclass of the nb_date class with the
%               frequency given by the frequency input.
%
% Examples:
%
% obj = nb_month(1,2012);
% obj = obj.convert(1);
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        first = 1; 
    end
    
    if numel(obj) > 1
        switch frequency
            case 1
                classConst = @nb_year;  
            case 2
                classConst = @nb_semiAnnual;  
            case 4
                classConst = @nb_quarter;  
            case 12
                return
            case 52
                classConst = @nb_week;    
            case 365
                classConst = @nb_day; 
            otherwise
                error([mfilename ':: Unsupported frequency ' int2str(frequency) '.'])
        end
        obj = nb_callMethod(obj,@convert,classConst,frequency,first);
        return
    end
    
    dow = obj.dayOfWeek;
    switch frequency
        case 1
            obj = obj.getYear();  
        case 2
            obj = obj.getHalfYear(); 
        case 4
            obj = obj.getQuarter();
        case 12
            % Do nothing
        case 52
            obj = obj.getWeek(first);    
        case 365
            obj = obj.getDay(first);
        otherwise
            error([mfilename ':: Unsupported frequency ' int2str(frequency) '.'])
    end
    obj.dayOfWeek = dow;
            
end

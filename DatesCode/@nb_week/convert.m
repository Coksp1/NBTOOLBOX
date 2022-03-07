function obj = convert(obj,frequency,first) %#ok
% Syntax:
%
% obj = convert(obj,frequency,first)
%
% Description:
%
% Convert the nb_week object ot the wanted frequency. The returned 
% variable will be an object which is of an subclass of the nb_date
% class.
% 
% Input:
% 
% - obj       : An object of class nb_week
%
% - frequency : The frequency to convert to. As a scalar.
%
% - first     : Does nothing. Just to make the code general for all
%               frequencies.
% 
% Output:
% 
% - obj       : An object of subclass of the nb_date class with the
%               frequency given by the frequency input.
%
% Examples:
%
% obj = nb_week(1,2012);
% obj = obj.convert(1);
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        first = 1; %#ok
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
                classConst = @nb_month; 
            case 52
                return  
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
            obj = obj.getMonth();
        case 52
            % Do nothing
        case 365
            obj = getDay(obj);
        otherwise
            error([mfilename ':: Unsupported frequency ' int2str(frequency) '.'])
    end
    obj.dayOfWeek = dow;
            
end

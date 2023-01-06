function output = minus(obj,aObj)
% Syntax:
% 
% output = minus(obj,aObj)
%
% Description:
%   
% Makes it possible to take an nb_day object minus another nb_day
% object and get the number of days between them.
% 
% It makes it also possible to take the difference between an 
% nb_day object and a string one one of the following formats:
% 'yyyyMm(m)Dd(d)', 'dd.mm.yyyy'
% 
% And last it makes it possible to substract the number of days 
% from an nb_day object an receive an nb_day representing the day
% the given number of days backward in time.
% 
% Input:
% 
% - obj  : A date string, an nb_day object or an integer.
% 
% - aObj : A date string, an nb_day object or an integer.
% 
% Output:
% 
% - output : The number of days between the given days. As a 
%            double
% 
%            or 
% 
%            An nb_day object representing the date the given
%            number of days backwards in time.
% 
% Examples:
% 
% output = obj - aObj;          % (both objects). Returns a double
% 
% output = obj - '2012M1D1';    % Returns a double
% 
% output = '2012M12D23' - obj;  % Returns a double
%
% output = obj - 1;             % Returns an object
%    
% same as
% 
% output = 1 - obj;             % Returns an object
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isnumeric(obj) || isnumeric(aObj)

        if isnumeric(aObj)
            output = plus(obj,-aObj);
        else
            output = plus(-obj,aObj);
        end

    else
        
        if ~isa(obj,'nb_day') 

            try
                obj = nb_day(obj);
            catch Err

                if isa(obj,'nb_date') 

                    freq1 = nb_date.getFrequencyAsString(obj.frequency);
                    freq2 = 'daily';
                    error([mfilename ':: Not the same freqency of the dates: ' freq1 ' compared to ' freq2])

                elseif ischar(obj)
                    error([mfilename ':: The date format ' obj ' are either of wrong frequency or the wrong daily date format.'])
                else
                    error([mfilename ':: It is not possible to substract an object of class ' class(obj) ' with an nb_day object'])
                end

            end
            
        else
            if numel(obj) > 1
                error([mfilename ':: The minus operator is only supported for scalar ' class(obj) ' objects.'])
            end
        end

        if ~isa(aObj,'nb_day')
            
            try
                aObj = nb_day(aObj);
            catch Err

                if isa(aObj,'nb_date')

                    freq2 = nb_date.getFrequencyAsString(aObj.frequency);
                    freq1 = 'daily';
                    error([mfilename ':: Not the same freqency of the dates: ' freq1 ' compared to ' freq2])

                elseif ischar(aObj)
                    error([mfilename ':: The date format ' aObj ' are either of wrong frequency or the wrong daily date format.'])
                else
                    error([mfilename ':: It is not possible to substract an nb_day object with an object of class ' class(aObj)])
                end

            end
        end

        output = obj.dayNr - aObj.dayNr;

    end

end

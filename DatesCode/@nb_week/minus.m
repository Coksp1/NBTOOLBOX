function output = minus(obj,aObj)
% Syntax:
% 
% output = minus(obj,aObj)
%
% Description:
%   
% Makes it possible to take an nb_week object minus another nb_week
% object and get the number of days between them.
% 
% It makes it also possible to take the difference between an 
% nb_week object and a string one one of the following formats:
% 'yyyyWw(w)', 'dd.mm.yyyy'
% 
% And last it makes it possible to substract the number of days 
% from an nb_week object an receive an nb_week representing the 
% week the given number of weeks backward in time.
% 
% Input:
% 
% - obj  : A date string, an nb_week object or an integer.
% 
% - aObj : A date string, an nb_week object or an integer.
% 
% Output:
% 
% - output : The number of days between the given days. As a 
%            double
% 
%            or 
% 
%            An nb_week object representing the date the given
%            number of days backwards in time.
% 
% Examples:
% 
% output = obj - aObj;          % (both objects). Returns a double
% 
% output = obj - '2012W1';      % Returns a double
% 
% output = '2012W12' - obj;     % Returns a double
%
% output = obj - 1;             % Returns an object
%    
% same as
% 
% output = 1 - obj;             % Returns an object
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isnumeric(obj) || isnumeric(aObj)

        if isnumeric(aObj)
            output = plus(obj,-aObj);
        else
            output = plus(-obj,aObj);
        end

    else

        if ~isa(obj,'nb_week') 

            try
                obj = nb_week(obj);
            catch Err

                if isa(obj,'nb_date')

                    freq1 = nb_date.getFrequencyAsString(obj.frequency);
                    freq2 = 'weekly';
                    error([mfilename ':: Not the same freqency of the dates: ' freq1 ' compared to ' freq2])

                elseif ischar(obj)
                    error([mfilename ':: The date format ' obj ' are either of wrong frequency or the wrong weekly date format.'])
                else
                    error([mfilename ':: It is not possible to substract an object of class ' class(obj) ' with an nb_week object'])
                end

            end

        else
            if numel(obj) > 1
                error([mfilename ':: The minus operator is only supported for scalar ' class(obj) ' objects.'])
            end
        end

        if ~isa(aObj,'nb_week')
            
            try
                aObj = nb_week(aObj);
            catch Err

                if isa(aObj,'nb_date')

                    freq2 = nb_date.getFrequencyAsString(aObj.frequency);
                    freq1 = 'daily';
                    error([mfilename ':: Not the same freqency of the dates: ' freq1 ' compared to ' freq2])

                elseif ischar(aObj)
                    error([mfilename ':: The date format ' aObj ' are either of wrong frequency or the wrong daily date format.'])
                else
                    error([mfilename ':: It is not possible to substract an nb_week object with an object of class ' class(aObj)])
                end

            end
        end

        output = obj.weekNr - aObj.weekNr;

    end

end

function output = minus(obj,aObj)
% STARTDOC
%
% Syntax:
% 
% output = minus(obj,aObj)
%
% Description:
%    
% Makes it possible to take an nb_month object minus another 
% nb_month object and get the number of months between them.
% 
% It makes it also possible to take the difference between an 
% nb_month object and a string one one of the following formats:
% 'yyyyMm(m)', 'dd.mm.yyyy'
% 
% And last it makes it possible to substract the number of months 
% from an nb_month object an receive an nb_month representing the 
% month the given number of months backward in time.
% 
% Input:
% 
% - obj  : A date string, an nb_month object or an integer.
% 
% - aObj : A date string, an nb_month object or an integer.
% 
% Output:
% 
% - output : The number of months between the given months. As a
%            double
% 
%            or 
% 
%            An nb_month object representing the date the given
%            number of months backwards in time.
% 
% Examples:
% 
% 
% output = obj - aObj;         % (both objects). Returns a double
% 
% output = obj - '31.01.2012'; % Returns a double
% 
% output = '31.01.2012' - obj; % Returns a double
%
% output = obj - 1;            % Returns an object
%    
% same as
% 
% output = 1 - obj;            % Returns an object
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isnumeric(obj) || isnumeric(aObj)

        if isnumeric(aObj)
            output = plus(obj,-aObj);
        else
            output = plus(-obj,aObj);
        end

    else
        
        if ~isa(obj,'nb_month') 

            try
                obj = nb_month(obj); 
            catch 

                if isa(obj,'nb_date') 

                    freq1 = nb_date.getFrequencyAsString(obj.frequency);
                    freq2 = 'monthly';
                    error([mfilename ':: Not the same freqency of the dates: ' freq1 ' compared to ' freq2])

                elseif ischar(obj)
                    error([mfilename ':: The date format ' obj ' are either of wrong frequency or the wrong monthly date format.'])
                else
                    error([mfilename ':: It is not possible to substract an object of class ' class(obj) ' with an nb_month object'])
                end

            end

        else
            if numel(obj) > 1
                error([mfilename ':: The minus operator is only supported for scalar ' class(obj) ' objects.'])
            end
        end

        if ~isa(aObj,'nb_month')

            try
                aObj = nb_month(aObj); 
            catch Err

                if isa(aObj,'nb_date')

                    freq2 = nb_date.getFrequencyAsString(aObj.frequency);
                    freq1 = 'monthly';
                    error([mfilename ':: Not the same freqency of the dates: ' freq1 ' compared to ' freq2])

                elseif ischar(aObj)
                    error([mfilename ':: The date format ' aObj ' are either of wrong frequency or the wrong monthly date format.'])
                else
                    error([mfilename ':: It is not possible to substract an nb_month object with an object of class ' class(aObj)])
                end

            end
        end

        output = obj.monthNr - aObj.monthNr;

    end

end

function output = minus(obj,aObj)
% Syntax:
% 
% output = minus(obj,aObj)
%
% Description:
%   
% Makes it possible to take an nb_quarter object minus another    
% nb_quarter object and get the number of quarters between them.
% 
% It makes it also possible to take the difference between an 
% nb_quarter object and a string one one of the following formats:
% 'yyyyQq', 'dd.mm.yyyy'
% 
% And last it makes it possible to substract the number of quarters 
% from an nb_quarter object an receive an nb_quarter representing 
% the quarter the given number of quarters backward in time.
% 
% Input:
% 
% - obj  : A date string, an nb_quarter object or an integer.
% 
% - aObj : A date string, an nb_quarter object or an integer.
% 
% Output:
% 
% - output : The number of quarters between the given quarters. As 
%            a double
% 
%            or 
% 
%            An nb_quarter object representing the date the given
%            number of quarter backwards in time.
% 
% Examples:
% 
% output = obj - aObj;          % (both objects). Returns a double
% 
% output = obj - '2012Q2';      % Returns a double
% 
% output = '2012Q3' - obj;      % Returns a double
%
% output = obj - 1;             % Returns an object
%    
% same as
% 
% output = 1 - obj;             % Returns an object
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

        if ~isa(obj,'nb_quarter') 

            try
                obj = nb_quarter(obj); 
            catch Err

                if isa(obj,'nb_date')

                    freq1 = nb_date.getFrequencyAsString(obj.frequency);
                    freq2 = 'quarterly';
                    error([mfilename ':: Not the same freqency of the dates: ' freq1 ' compared to ' freq2])

                elseif ischar(obj)
                    error([mfilename ':: The date format ' obj ' are either of wrong frequency or the wrong quarterly date format.'])
                else
                    error([mfilename ':: It is not possible to substract an object of class ' class(obj) ' with an nb_quarter object'])
                end

            end
            
        else
            if numel(obj) > 1
                error([mfilename ':: The minus operator is only supported for scalar ' class(obj) ' objects.'])
            end
        end

        if ~isa(aObj,'nb_quarter')

            try
                aObj = nb_quarter(aObj);
            catch Err

                if isa(aObj,'nb_date') 

                    freq2 = nb_date.getFrequencyAsString(aObj.frequency);
                    freq1 = 'quarterly';
                    error([mfilename ':: Not the same freqency of the dates: ' freq1 ' compared to ' freq2])

                elseif ischar(aObj)
                    error([mfilename ':: The date format ' aObj ' are either of wrong frequency or the wrong quarterly date format.'])
                else
                    error([mfilename ':: It is not possible to substract an nb_quarter object with an object of class ' class(aObj)])
                end

            end
        end

        output = obj.quarterNr - aObj.quarterNr;

    end

end

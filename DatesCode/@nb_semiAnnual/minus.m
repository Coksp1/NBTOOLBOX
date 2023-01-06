function output = minus(obj,aObj)
% Syntax:
% 
% output = minus(obj,aObj)
%
% Description:
%    
% Makes it possible to take an nb_semiAnnual object minus another    
% nb_semiAnnual object and get the number of half years between 
% them.
% 
% It makes it also possible to take the difference between an 
% nb_semiAnnual object and a string on one of the following 
% formats: 'yyyySs', 'dd.mm.yyyy'
% 
% And last it makes it possible to substract the number of half 
% years from an nb_semiAnnual object an receive an nb_semiAnnual 
% representing the half year the given number of half years 
% backward in time.
% 
% Input:
% 
% - obj  : A date string, an nb_semiAnnual object or an integer.
% 
% - aObj : A date string, an nb_semiAnnual object or an integer.
% 
% Output:
% 
% - output : The number of years between the given half years. As a 
%            double
% 
%            or  
% 
%            An nb_semiAnnual object representing the date the 
%            given number of half years backwards in time.
% 
% Examples:
% 
% output = obj - aObj;    % (both objects). Returns a double
% 
% output = obj - '2012';  % Returns a double
% 
% output = '2012' - obj;  % Returns a double
%
% output = obj - 1;       % Returns an object
%    
% same as
% 
% output = 1 - obj;       % Returns an object
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

        if ~isa(obj,'nb_semiAnnual') 

            try
                obj = nb_semiAnnual(obj); 
            catch Err

                if isa(obj,'nb_date')

                    freq1 = nb_date.getFrequencyAsString(obj.frequency);
                    freq2 = 'semiannually';
                    error([mfilename ':: Not the same freqency of the dates: ' freq1 ' compared to ' freq2])

                elseif ischar(obj)
                    error([mfilename ':: The date format ' obj ' are either of wrong frequency or the wrong semiannually date format.'])
                else
                    error([mfilename ':: It is not possible to substract an object of class ' class(obj) ' with an nb_semiAnnual object'])
                end

            end

        else
            if numel(obj) > 1
                error([mfilename ':: The minus operator is only supported for scalar ' class(obj) ' objects.'])
            end
        end

        if ~isa(aObj,'nb_semiAnnual')

            try
                aObj = nb_semiAnnual(aObj);
            catch Err

                if isa(aObj,'nb_date') 

                    freq2 = nb_date.getFrequencyAsString(aObj.frequency);
                    freq1 = 'semiannually';
                    error([mfilename ':: Not the same freqency of the dates: ' freq1 ' compared to ' freq2])

                elseif ischar(aObj)
                    error([mfilename ':: The date format ' aObj ' are either of wrong frequency or the wrong semiannually date format.'])
                else
                    error([mfilename ':: It is not possible to substract an nb_semiAnnual object with an object of class ' class(aObj)])
                end

            end
        end

        output = obj.halfYearNr - aObj.halfYearNr;

    end

end

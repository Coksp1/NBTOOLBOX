function varargout = toDates(obj,periods,format,newFreq,first)
% Syntax:
% 
% varargout = toDates(obj,periods,format,newFreq,first)
%
% Description:
%   
% Get a cellstr array of the dates ahead
%         
% Input:
% 
% - obj     : An object of class nb_year
% 
% - periods : The periods wanted, must be given as a double array.
%             E.g. 1:20. 
% 
% - format  : > 'xls'     : 'dd.mm.yyyy'
%             > 'vintage' : 'yyyymmdd'
%             > 'nb_date' : Vector of nb_year 
%             > otherwise : 'yyyy'
% 
% - newFreq : Give a error if you are trying to change the 
%             frequency. 1 is the only appropriate input value.
% 
% - first  : Give 1 if you want the date strings to represent the 
%            first day of the year ('01.01.yyyy'), otherwise last 
%            day of the year will be given ('31.12.yyyy'). Only 
%            when format is given as 'xls'
%
% Output:
% 
% - varargout{1} : A cell array of the wanted dates.
% 
% - varargout{2} : Locations of the returned dates.
% 
% Examples:
%
% dates             = obj.toDates(0:20);
% dates             = obj.toDates(0:20,'xls');
% 
% Written by Kenneth S. Paulsen
            
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 5
        first = 1;
        if nargin < 4
            newFreq = 1;
            if nargin < 3
                format = '';
            end
        end
    end
    
    if newFreq ~= obj.frequency
        error([mfilename ':: It is not possible to convert the date format to a higher freqency. '...
                                         'I.e. from ' nb_date.getFrequencyAsString(obj.frequency) ' to ' nb_date.getFrequencyAsString(newFreq)])
    end

    if isempty(periods)
        error([mfilename ':: The input ''periods'' is empty, but it must be double (vector). E.g. -10:10.'])
    elseif ~isnumeric(periods)
        error([mfilename ':: The input ''periods'' must be double (vector). E.g. -10:10.'])
    end

    periods         = periods(:);
    SampleStartYear = obj.year;
    dates           = periods + SampleStartYear;

    if ~isempty(dates)
        dates = strtrim(cellstr(int2str(dates)));
    end
    
    if strcmpi(format, 'nb_date')
        datesT(length(periods),1) = nb_year();
        for ii = 1:length(periods)
            datesT(ii)           = nb_year(dates{ii});
            datesT(ii).dayOfWeek = obj.dayOfWeek;
        end
        dates = datesT;
    elseif strcmpi(format,'xls')
        if first
            dates = strcat('01.01.', dates);
        else
            dates = strcat('31.12.', dates);
        end
    elseif strcmpi(format,'vintage')
        if first
            dates = strcat(dates,'0101');
        else
            dates = strcat(dates,'1231');
        end
    end
    
    if nargout == 1
        varargout{1} = dates;
    elseif nargout == 2
        varargout{1} = dates;
        varargout{2} = periods + 1; 
    elseif nargout == 0
        varargout{1} = dates;
    else
        error([mfilename ':: To many output arguments'])
    end
    
end

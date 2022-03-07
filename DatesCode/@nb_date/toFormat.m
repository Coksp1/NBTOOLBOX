function dates = toFormat(start,finish,format,language,first)
% Syntax:
%
% dates = toFormat(start,finish,format,language,first)
%
% Description:
%
% Convert dates vector to a given format.
% 
% Input:
% 
% - start    : An object of a subclass of the nb_date class.
%
% - finish   : An object of a subclass of the nb_date class.
%
% - format   : See the format input to the nb_date.format2string
%              method.
% 
% - language : 'norwegian' or 'english' (default). Only important for the
%              'monthtext' or 'Monthtext' patterns.
%
% - first    : Give false to return the latest period when converted  
%              to a higher frequency. Default is true, i.e. first 
%              period.
%
% Output:
% 
% - vint     : A cellstr.
%
% See also:
% nb_date.format2string
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        first = true;
        if nargin < 4
            language = '';
            if nargin < 3
                format = 'yyyyddmm';
            end
        end
    end

    if isa(start,'char')
        start = nb_date.date2freq(start);
    elseif ~isa(start,'nb_date')
        error([mfilename ':: The start input must be a nb_date object.'])
    end
    
    if isa(finish,'char')
        finish = nb_date.date2freq(finish);
    elseif ~isa(finish,'nb_date')
        error([mfilename ':: The finish input must be a nb_date object.'])
    end

    if start.frequency ~= finish.frequency
        error([mfilename ':: The start and finish inputs must have the same frequency.'])
    end
    
    if start > finish    
        error([mfilename ':: The start input must come before the finish input.'])
    end
    periods = (finish - start) + 1;
    dates   = cell(periods,1);
    for ii = 1:periods
        dateT     = start + (ii-1);
        dates{ii} = nb_date.format2string(dateT,format,language,first);
    end 
        
end

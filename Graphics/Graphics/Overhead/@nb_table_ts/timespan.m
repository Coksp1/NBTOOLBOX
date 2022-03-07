function dateString = timespan(obj,language,freq)
% Syntax:
% 
% dateString = timespan(obj,language,freq)
% 
% Description:
% 
% Get the timespan of the table as a string. On the PPR format.
% 
% Input :
% 
% - obj        : An object of class nb_table_ts
% 
% - language   : 'english' or 'norwegian'. 'norwegian' is default
%                
% - freq       : The wanted frequency of the timespan 
%
% Output :
% 
% - dateString : A string with the timespan of the graph 
%                represented by this object.
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        freq = [];
        if nargin < 2
            language = 'norwegian';
        end
    end

    sDate = obj.startTable;
    eDate = obj.endTable;
    if ~isempty(freq)
        sDate = convert(sDate,freq);
        eDate = convert(eDate,freq);
    end
    
    switch language

        case {'english','engelsk'}

            if sDate.frequency == 52
                extra = 0;
            else
                extra = 1;
            end
            dateString = [sDate.toString('mprenglish'),' - ', eDate.toString('mprenglish',extra)];

        otherwise

            dateString = [sDate.toString('pprnorsk'),' - ', eDate.toString('pprnorsk',0)];

    end

end

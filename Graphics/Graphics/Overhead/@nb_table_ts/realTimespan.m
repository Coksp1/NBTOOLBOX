function dateString = realTimespan(obj,language,freq)
% Syntax:
% 
% dateString = realTimespan(obj,language,freq)
% 
% Description:
% 
% Get the timespan of the data behind a table which is not nan or 
% infinite, as a string. On the PPR format.
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

    % Find the real start date of the graph
    %--------------------------------------------------------------
    DB            = getData(obj);
    isFinite      = isfinite(DB.data);
    isFinite      = any(any(isFinite,2),3);
    first         = find(isFinite,1);
    realStartDate = DB.startDate + first - 1;
    if realStartDate >= obj.startTable
        startDate = realStartDate;
    else
        startDate = obj.startTable;
    end
    
    % Find the real end date of the graph
    %--------------------------------------------------------------
    last        = find(isFinite,1,'last');   
    realEndDate = DB.startDate + last - 1;
    if realEndDate >= obj.endTable
        endDate = obj.endGraph;
    else
        endDate = realEndDate;
    end
    
    if ~isempty(freq)
        startDate = convert(startDate,freq);
        endDate   = convert(endDate,freq);
    end
    
    % Get the timespan as a string on the wnated language
    %--------------------------------------------------------------
    switch language
        case {'english','engelsk'}
            if startDate.frequency == 52
                extra = 0;
            else
                extra = 1;
            end
            dateString = [startDate.toString('mprenglish'),' - ', endDate.toString('mprenglish')];
        otherwise
            dateString = [startDate.toString('pprnorsk'),' - ', endDate.toString('pprnorsk',0)];
    end

end

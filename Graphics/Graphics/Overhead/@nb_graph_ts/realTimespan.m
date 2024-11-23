function dateString = realTimespan(obj,language,freq)
% Syntax:
% 
% dateString = realTimespan(obj,language,freq)
% 
% Description:
% 
% Get the timespan of the data behind a graph which is not nan or 
% infinite, as a string. On the PPR format.
% 
% Input :
% 
% - obj        : An object of class nb_graph_ts
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
% Examples:
% 
% data        = nb_ts([2;1;2],'','2012Q1','Var1');
% obj         = nb_graph_ts(data);
% dateString  = realTimespan(obj);
% dateStringE = realTimespan(obj,'english');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        freq = [];
        if nargin < 2
            language = 'norwegian';
        end
    end

    % Find the real start date of the graph
    %--------------------------------------------------------------
    DB = getData(obj);
    if isa(DB,'nb_cs')
        dateString = '';
        return
    end
    isFinite      = isfinite(DB.data);
    isFinite      = any(any(isFinite,2),3);
    first         = find(isFinite,1);
    realStartDate = DB.startDate + first - 1;
    if or(realStartDate == obj.startGraph,realStartDate > obj.startGraph)
        startDate = realStartDate;
    else
        startDate = obj.startGraph;
    end
    
    % Find the real end date of the graph
    %--------------------------------------------------------------
    last        = find(isFinite,1,'last');   
    realEndDate = DB.startDate + last - 1;
    if or(realEndDate == obj.endGraph,realEndDate > obj.endGraph)
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
            dateString = [startDate.toString('mprenglish'),' ' nb_dash('en-dash') ' ', endDate.toString('mprenglish',extra)];
        otherwise
            dateString = [startDate.toString('pprnorsk'),' ' nb_dash('en-dash') ' ', endDate.toString('pprnorsk',0)];
    end

end

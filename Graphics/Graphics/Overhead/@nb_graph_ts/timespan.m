function dateString = timespan(obj,language,freq)
% Syntax:
% 
% dateString = timespan(obj,language,freq)
% 
% Description:
% 
% Get the timespan of the graph as a string. On the PPR format.
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
% dateString  = timespan(obj);
% dateStringE = timespan(obj,'english');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        freq = [];
        if nargin < 2
            language = 'norwegian';
        end
    end
    
    if isprop(obj,'printing2PDF')
        printing2PDF = obj.printing2PDF;
    else
        printing2PDF = false;
    end

    sDate = obj.startGraph;
    eDate = obj.endGraph;
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
            dateString = [sDate.toString('mprenglish'),' ' nb_dash('en-dash',printing2PDF) ' ', eDate.toString('mprenglish',extra)];

        otherwise

            dateString = [sDate.toString('pprnorsk'),' ' nb_dash('en-dash',printing2PDF) ' ', eDate.toString('pprnorsk',0)];

    end

end

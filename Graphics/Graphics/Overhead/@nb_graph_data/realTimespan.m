function obsString = realTimespan(obj, language) %#ok
% Syntax:
% 
% dateString = realTimespan(obj)
% 
% Description:
% 
% Get the timespan of the data behind a graph which is not nan or 
% infinite, as a string. On the PPR format.
% 
% Input :
% 
% - obj        : An object of class nb_graph_data
% 
% - language   : Has nothing to say
%                
% 
% Output :
% 
% - obsString  : A string with the span of the graph represented 
%                by this object.
% 
% Examples:
% 
% data        = nb_data([2;1;2],'','1','Var1');
% obj         = nb_graph_data(data);
% dateString  = realTimespan(obj);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        language = ''; %#ok (Makes thing generic with nb_graph_ts)
    end

    % Find the real start date of the graph
    %--------------------------------------------------------------
    if isempty(obj.variableToPlotX)
        
        DB            = obj.DB;
        isFinite      = isfinite(DB.data);
        isFinite      = any(any(isFinite,2),3);
        first         = find(isFinite,1);
        realStartObs  = DB.startDate + first - 1;

        if realStartObs >= obj.startGraph
            startObs = realStartObs;
        else
            startObs = obj.startGraph;
        end
        
    else  
        startObs = getRealStartObs(obj.DB);        
    end
    
    % Find the real end date of the graph
    %--------------------------------------------------------------
    if isempty(obj.variableToPlotX)
        
        isFinite    = isfinite(DB.data);
        isFinite    = any(any(isFinite,2),3);
        first       = find(isFinite,1,'last');   
        realEndObs  = DB.startDate + first - 1;

        if realEndObs >= obj.endGraph
            endObs = obj.endGraph;
        else
            endObs = realEndObs;
        end
        
    else      
        endObs = getRealEndObs(obj.DB);   
    end
    
    % Get the span as a string on the wnated language
    %--------------------------------------------------------------
    obsString = [int2str(startObs),' - ', int2str(endObs)];

end

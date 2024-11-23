function dateString = timespan(obj, language) %#ok
% Syntax:
% 
% dateString = timespan(obj, language)
% 
% Description:
% 
% Get the timespan of the graph as a string. On the PPR format.
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
% - dateString : A string with the span of the graph 
%                represented by this object.
% 
% Examples:
% 
% data        = nb_data([2;1;2],'','1','Var1');
% obj         = nb_graph_data(data);
% dateString  = timespan(obj);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        language = ''; %#ok
    end

    if isempty(obj.variableToPlotX)
        start  = obj.startGraph;
        finish = obj.endGraph;
    else
        start  = obj.DB.startObs;
        finish = obj.DB.endObs;
    end
    
    dateString = [int2str(start),' - ', int2str(finish)];

end

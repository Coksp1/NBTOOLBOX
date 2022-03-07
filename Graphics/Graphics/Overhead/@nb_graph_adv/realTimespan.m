function dateString = realTimespan(obj)
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
% - obj        : An object of class nb_graph_ts
% 
% Output :
% 
% - dateString : A string with the timespan of the graph 
%                represented by this object. The language of this 
%                string will depend on the language of the language
%                property of the plotter object.
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(obj.plotter,'nb_graph_ts') || isa(obj.plotter,'nb_table_ts')
        dateString = realTimespan(obj.plotter);       
    else   
        dateString = '';
    end

end

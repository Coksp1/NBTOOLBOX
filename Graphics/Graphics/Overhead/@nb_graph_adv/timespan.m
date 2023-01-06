function dateString = timespan(obj)
% Syntax:
% 
% dateString = timespan(obj)
% 
% Description:
% 
% Get the timespan of the graph as a string. On the PPR format.
% 
% Input :
% 
% - obj        : An object of class nb_graph_adv, with the property
%                plotter set to an nb_graph_ts object. Will return
%                an empty string otherwise.
% 
% Output :
% 
% - dateString : A string with the timespan of the graph 
%                represented by this object. The language of this 
%                string will depend on the language of the language
%                property of the plotter object.
% 
% Examples:
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isa(obj.plotter,'nb_graph_ts') || isa(obj.plotter,'nb_table_ts')
        dateString = timespan(obj.plotter);
    else  
        dateString = ''; 
    end

end

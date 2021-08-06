function data = getData(obj)
% Syntax:
% 
% data = getData(obj)
% 
% Description:
% 
% Get the data of the graph
% 
% Input:
% 
% - obj            : An object of class nb_graph_adv
% 
% Output:
%
% - data     : As a nb_ts, nb_cs or nb_data object. 
%
% Example:
% 
% data = obj.getData();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    data = getData(obj.plotter);
    
end

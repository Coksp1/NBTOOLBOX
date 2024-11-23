function data = getData(obj,~)
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
% - obj      : An object of class nb_graph_cs
% 
% Output:
%
% - data     : As an nb_cs object
%
% Example:
% 
% data = obj.getData();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    types = getPlottedTypes(obj);
    vars  = getPlottedVariables(obj);
    if isempty(types) || isempty(vars)
        data = nb_cs;
        return
    end
    
    % Only include the plotted variables
    data = obj.DB;
    data = data.window(types,vars,obj.page);
    data = reorder(data,vars);

end

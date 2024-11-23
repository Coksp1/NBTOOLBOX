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
% - obj  : An object of class nb_graph_bd
%
% Output:
%
% - data : As an nb_bd object.
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the plotted variables
    vars = obj.getPlottedVariables();
    if isempty(vars)
        data = nb_bd();
        return
    end

    % Get the start and end date
    startD = obj.startGraph;
    if startD < obj.DB.startDate
        startD = obj.DB.startDate;
    end

    finishD = obj.endGraph;
    if finishD > obj.DB.endDate
        finishD = obj.DB.endDate;
    end

    % Interpret the nanVariables input
    data  = obj.DB;
    
    % Only include the plotted variables
    data = data.window(startD,finishD,vars,obj.page);
    data = reorder(data,vars);

end



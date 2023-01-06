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
% - obj      : An object of class nb_graph_data
% 
% Output:
%
% - data     : As an nb_data object
%
% Example:
% 
% data = obj.getData();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the plotted variables
    vars = obj.getPlottedVariables();
    if isempty(vars)
        data = nb_data();
        return
    end
    
    % Get the start and end date
    startD = obj.startGraph;
    if startD < obj.DB.startObs
        startD = obj.DB.startObs;
    end

    finishD = obj.endGraph;
    if finishD > obj.DB.endObs
        finishD = obj.DB.endObs;
    end

    % Only include the plotted variables
    data = obj.DB.window(startD,finishD,vars,obj.page);
    data = reorder(data,vars);

end

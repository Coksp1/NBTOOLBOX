function plotter = plotData(obj,plotLastContextOnly)
% Syntax:
%
% plotter = plotData(obj,plotLastContextOnly)
%
% Description:
%
% Plot real-time data, including transformed data.
% 
% Input:
% 
% - obj                 : A scalar nb_calculate_vintages object.
% 
% - plotLastContextOnly : Set to true to only plot the data at the last
%                         context. Default is false.
% 
% Output:
% 
% - plotter : An object of class nb_graph_ts. Use the graphSubPlots method 
%             or the nb_graphSubPlotGUI class to diplay the graphs.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        plotLastContextOnly = false;
    end

    if numel(obj) ~= 1
        error([mfilename ':: This method only handle scalar nb_calculate_vintages objects.'])
    end
    
    if obj.options.updateAtEachContext || plotLastContextOnly
        data = fetchLastContext(obj.options.dataSource);
    else
        data = fetch(obj.options.dataSource);
    end
    nSteps          = 0;
    transformations = obj.transformations;
    model           = obj.options.model;
    plotter         = nb_model_vintages.plotDataStatic(data,model,transformations,nSteps);  
    
end

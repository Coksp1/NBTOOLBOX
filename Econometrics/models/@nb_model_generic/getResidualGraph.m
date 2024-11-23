function plotter = getResidualGraph(obj)
% Syntax:
%
% plotter = getResidualGraph(obj)
%
% Description:
%
% Get residual graph from the given estimator. The returned will
% be an object of class nb_graph, which can you can call the
% graphInfoStruct method on to get the figure(s).
% 
% Caution : Will only plot the residual of the last period of recursive
%           estimation.
%
% Caution : For quantile regression this will only report the graph for
%           the median regression.
%
% Input:
% 
% - obj     : An object of class nb_model_generic (or a subclass of 
%             this class).
% 
% Output:
% 
% - plotter : An object of class nb_graph. Use the graphInfoStruct method
%             or the nb_graphInfoStructGUI class.
%
% Examples:
%
% plotter = getResidualGraph(obj);
% plotter.graphInfoStruct();
%
% See also:
% nb_graph, nb_graph_ts, nb_graph_cs
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This function does not support a vector of nb_model_generic inputs.'])
    end
    opt = obj.estOptions(end);
    if opt.recursive_estim
        error([mfilename ':: Cannot produce the residual graph when recursive estimation has been done.'])
    end
    
    res = obj.results;
    if isempty(fieldnames(res))
        error([mfilename ':: Estimation not done. Call the estimate method.'])
    end

    % Get the data to plot
    %--------------------------------------------------------------
    aFunc  = str2func([opt.estimator '.getDependent']);
    actual = aFunc(res,opt);
    if isempty(actual)
        plotter = nb_graph_ts();
        return
    end
    
    pFunc     = str2func([opt.estimator '.getPredicted']);
    predicted = pFunc(res,opt);
    rFunc     = str2func([opt.estimator '.getResidual']);
    residual  = rFunc(res,opt);
    numVars   = actual.numberOfVariables;
    aVars     = actual.variables;
    rVars     = residual.variables;
    pVars     = predicted.variables; 
    nPage     = actual.numberOfDatasets;
    dataTP    = [actual.window('','','',nPage),residual.window('','','',nPage),predicted.window('','','',nPage)];
    
    % Get the expression to be graphed
    %--------------------------------------------------------------
    plottedVar = cell(1,numVars*2);
    for ii = 1:numVars
        plottedVar{ii*2 - 1} = ['[' aVars{ii} ',' pVars{ii} ']'];
        plottedVar{ii*2}     = rVars{ii};
    end
        
    % Create the GraphStruct input to the nb_graph class
    %----------------------------------------------------------
    GraphStruct = struct();
    for ii = 1:numVars
        field = strrep(aVars{ii},' ','_');
        GraphStruct.(field) = {plottedVar{ii*2 - 1},  {'title', aVars{ii}, 'colorOrder',{'black','orange'},'legends',{'Actual','Predicted'}};
                               plottedVar{ii*2},{'title', aVars{ii}, 'colorOrder',{'blue'},'legends',{'Residual'}}};
    end
        
    % Initilize nb_graph_ts object
    %----------------------------------------------------------
    plotter = nb_graph_ts(dataTP);
    plotter.set('GraphStruct',GraphStruct,'baseline',0);
        
end

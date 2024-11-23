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
% - obj     : An object of class nb_model_recursive_detrending.
% 
% Output:
% 
% - plotter : An object of class nb_graph.
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

    error([mfilename ':: Cannot produce the residual graph when recursive estimation has been done.'])
       
end

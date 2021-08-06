function plotter = plot(obj,x,type)
% Syntax:
%
% plotter = plot(obj,type)
%
% Description:
%
% Graph either the PDF or CDF of the distribution
% 
% Input:
% 
% - obj  : A nb_distribution object.
%
% - x    : The values to evaluate the distribution. x must be a Nx1 double.
%
%          If not provided or empty the full domain of the distribution(s)
%          will be used
%
% - type : A string with either 'pdf' (default) or 'cdf'
% 
% Output:
% 
% - plotter : A nb_graph_data object. If nargout is 0 the graph will be
%             plotted automatically, otherwise you need to call the graph
%             method on the plotter object.
%
% Examples:
%
% obj = nb_distribution
% plot(obj)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'pdf';
        if nargin < 2
            x = [];
        end
    end

    data    = obj.asData(x, type);
    vars    = data.variables;
    ind     = strcmp(vars,'domain');
    vars    = vars(~ind);
    plotter = nb_graph_data(data);
    plotter.set('variableToPlotX','domain',...
                'variablesToPlot',vars);
            
    if nargout == 0
        plotter.graph();
    end
end

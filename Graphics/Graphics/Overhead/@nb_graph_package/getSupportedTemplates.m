function templates = getSupportedTemplates(obj)
% Syntax:
%
% templates = getSupportedTemplates(obj)
%
% Description:
%
% Get the the templates that are shared among the graph. If some graphs
% does not have an assigned template the output will be {}.
% 
% Input:
% 
% - obj       : An object of class nb_graph_package.
% 
% Output:
%
% - templates : A cellstr with the shared templates.
%
% See also:
% nb_graph_package
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
    
    if isempty(obj.graphs)
        templates = {};
        return
    end

    templates = getTemplatesOne(obj.graphs{1});
    if isempty(templates)
        return
    end
    for ii = 2:length(obj.graphs)
        templatesT = getTemplatesOne(obj.graphs{2});
        templates  = intersect(templates,templatesT);
        if isempty(templates)
            break
        end
    end
    
end

function templates = getTemplatesOne(graph)

    if isa(graph,'nb_graph_adv')
        if isempty(graph.plotter(1).template)
            templates = {};
        else
            templates = fieldnames(graph.plotter(1).template)';
        end
    else
        templates = {};
    end

end

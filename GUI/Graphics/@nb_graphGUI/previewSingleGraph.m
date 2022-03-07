function previewSingleGraph(gui,~,~)
% Syntax:
%
% previewSingleGraph(gui,~,~)
%
% Description:
%
% Part of DAG. Preview the graph using the extended template.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isa(gui.plotterAdv,'nb_graph_adv')
        nb_infoWindow('Only advanced graphs can be previewed.')
        return
    end
    
    % Create a graph package and add the graph to it so we can simply use
    % the original preview function.
    package      = nb_graph_package(1,1);
    package.flip = 1;
    iden         = gui.plotterName;
    package.add(gui.plotterAdv,iden);
    
    % Preview the graph
    lang = gui.plotter.language;
    package.previewExtended(lang,false);

end

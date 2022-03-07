function createDefaultPlotter(gui)
% Syntax:
%
% createDefaultPlotter(gui)
%
% Description:
%
% Part of DAG. Create an empty 2 x 2 panel of nb_graph_ts objects
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotters(4) = nb_graph_ts;
    for ii = 1:4
        setSpecial(plotters(ii),'fontUnits','normalized');
    end
    
    if isa(gui.parent,'nb_GUI')
        for ii = 1:4
            setSpecial(plotters(ii),'localVariables',gui.parent.settings.localVariables);
        end
    end
    
    gui.plotter = nb_graph_subplot(plotters(1),plotters(2),plotters(3),plotters(4));
    
end

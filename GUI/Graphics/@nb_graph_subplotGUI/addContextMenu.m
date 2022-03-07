function addContextMenu(gui,plotter)
% Syntax:
%
% addContextMenu(gui,plotter)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    addDefaultContextMenu(plotter);
    if isa(plotter,'nb_graph_adv')
        tempUICMenu = get(plotter.plotter,'UIContextMenu');
    else
        tempUICMenu = get(plotter,'UIContextMenu');
    end
        
    % Add copy and past menus
    uimenu(tempUICMenu,'Label','Copy','separator','on','callback',{@gui.copy,plotter});
    uimenu(tempUICMenu,'Label','Paste','callback',{@gui.paste,plotter});
    uimenu(tempUICMenu,'Label','Delete','callback',{@gui.deleteGraph,plotter});

end

function dumpGraphs(gui)
% Syntax:
%
% dumpGraphs(gui)
%
% Description:
%
% Part of DAG. Dump all of the graph objects of the imported package to 
% the main program using the identifiers of the graph objects as save
% names
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    pack        = gui.package.graphs;
    identifiers = gui.package.identifiers;
    appGraphs   = gui.parent.graphs;
    for hh = 1:size(pack,2)
        
        saveName         = identifiers{hh};
        tPlotter         = pack{hh};
        tPlotter.plotter = nb_importGraphGUI.checkObject(tPlotter.plotter);
        try
            appGraphs.(saveName) = tPlotter;
        catch %#ok<CTCH>
            nb_errorWindow(['Could not dump the graph ' identifiers{hh} ', because of invalid savename! '...
                            'It includes invalid characters (#¤ etc), starts with a number or has spaces.'])
            return 
        end
        
        % Assign it back to the package
        pack{hh} = tPlotter;
       
    end
    
    gui.parent.graphs  = appGraphs;
    gui.package.graphs = pack;
    
end

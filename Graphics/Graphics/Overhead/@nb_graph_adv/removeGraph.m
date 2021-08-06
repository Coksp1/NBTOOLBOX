function removeGraph(obj)
% Syntax:
%
% removeGraph(obj)
%
% Description:
%
% Add another graph to a 1 x 2 panel.
% 
% Input:
% 
% - obj     : A nb_graph_adv object.
% 
% - another : A nb_graph object.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if size(obj.plotter,2) < 2
        error([mfilename,':: Cannot reomve a graph when only one graph is stored.'])
    end
    obj.plotter = obj.plotter(1);

end

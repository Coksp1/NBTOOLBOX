function addGraph(obj,another)
% Syntax:
%
% addGraph(obj,another)
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

    if size(obj.plotter,2) > 1
        error([mfilename,':: Cannot add more than one extra graph to the nb_graph_adv class.'])
    end
    obj.plotter = [obj.plotter,another];

end

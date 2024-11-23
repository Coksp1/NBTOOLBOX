function obj = update(obj,warningOff,inGUI)
% Syntax:
% 
% obj = update(obj)
% 
% Description:
% 
% Update the data source of the nb_graph_adv object. I.e update
% the data source of the plotter property.
%
% See the update method of the nb_cs or nb_ts class for more on how 
% to make the data of the graph updateable.
% 
% Input:
% 
% - obj      : An object of class nb_graph_adv
% 
% Output:
% 
% - obj      : An object of class nb_graph_adv, where the data is 
%              updated. 
%     
% Examples:
%
% obj.update();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        inGUI = 'off';
        if nargin < 2
            warningOff = 'on';
        end
    end
    for ii = 1:length(obj.plotter)
        obj.plotter(ii) = update(obj.plotter(ii),warningOff,inGUI);
    end
    
end

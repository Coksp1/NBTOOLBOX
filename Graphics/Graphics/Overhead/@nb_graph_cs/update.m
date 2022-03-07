function obj = update(obj,warningOff,inGUI)
% Syntax:
% 
% obj = update(obj)
% 
% Description:
% 
% Update the data source of the figure
%
% See the update method of the nb_cs class for more on how to make
% the data of the graph updateable.
% 
% Input:
% 
% - obj      : An object of class nb_graph_cs
% 
% Output:
% 
% - obj      : An object of class nb_graph_cs, where the data is 
%              updated. 
%     
% Examples:
%
% obj.update();
% 
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        inGUI = 'off';
        if nargin < 2
            warningOff = 'on';
        end
    end

    obj.DB = update(obj.DB,warningOff,inGUI);

end

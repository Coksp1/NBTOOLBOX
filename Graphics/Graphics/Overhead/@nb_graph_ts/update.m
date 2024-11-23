function obj = update(obj,warningOff,inGUI)
% Syntax:
% 
% obj = update(obj)
% 
% Description:
% 
% Update the data source of the figure
% 
% See the update method of the nb_ts classes for more on how to make the  
% data of the graph updateable.
%
% Input:
% 
% - obj      : An object of class nb_graph_ts
% 
% Output:
% 
% - obj      : An object of class nb_graph_ts, where the data is 
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
    
    if ~isempty(obj.stopUpdate)
        now  = str2double(nb_clock());
        stop = str2double(obj.stopUpdate);
        if now < stop 
            obj.DB = update(obj.DB,warningOff,inGUI);
        else
            return
        end      
    else
        obj.DB = update(obj.DB,warningOff,inGUI);
    end
    
    if ~obj.manuallySetStartGraph
        obj.startGraph = obj.DB.startDate;
    end
    
    if ~obj.manuallySetEndGraph
        obj.endGraph = obj.DB.endDate;
    end

end

function obj = delete(obj,graphObj)
% Syntax:
% 
% obj = delete(obj,graphObj)
% 
% Description:
% 
% Delete specified graph object if found.
% 
% Caution : When an nb_graph_ts or nb_graph_cs object is added to
%           an nb_graph_subplot object, it will be copied. So if 
%           you provided the same object as you add, it will not be
%           found and deleted.
%
% Input:
% 
% - obj      : An object of class nb_graph_subplot
% 
% - graphObj : An object of class nb_graph_ts or nb_graph_cs.
%
% Example:
% 
% obj.delete(graphObj);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    for ii = 1:size(obj.graphObjects,2)
       
        if obj.graphObjects{ii} == graphObj
            
            obj.graphObjects = [obj.graphObjects(1:ii-1),obj.graphObjects(ii+1:end)];
            break
        end
        
    end
    
end

function copiedObject = add(obj,graphObj)
% Syntax:
% 
% add(obj,graphObj)
% 
% Description:
% 
% Adds a graph object to the subplot object.
% 
% Caution : This function will copy the provided object before its
%           adds the object to the nb_graph_subplot object.
%
% Input:
% 
% - obj       : An object of class nb_graph_subplot
% 
% - graphObj  : An object of class nb_graph_ts or nb_graph_cs.
%
% Example:
% 
% obj.add(graphObj);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(graphObj,'nb_graph_obj') || isa(graphObj,'nb_graph_adv')
        copiedObject     = copy(graphObj);
        obj.graphObjects = [obj.graphObjects, {copiedObject}];
    else
        error([mfilename ':: The added graph object must be of class nb_graph_obj or nb_graph_adv'])
    end
    
end

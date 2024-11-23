function copiedGraph = reset(obj,oldGraphObj,newGraphObj)
% Syntax:
% 
% copiedGraph = reset(obj,oldGraphObj,newGraphObj)
% 
% Description:
% 
% Reset specified graph object if found, with the newGraphObj.
% Will give an error if not found.
%
% Caution : If the resetting succeds the newGraphObj will be 
%           copied.
% 
% Caution : When an nb_graph_ts or nb_graph_cs object is added to
%           an nb_graph_subplot object, it will be copied. So if 
%           you provided the same object as you add (as the 
%           oldGraphObj), it will not be found and a error will 
%           occure.
%
% Input:
% 
% - obj         : An object of class nb_graph_subplot
% 
% - oldGraphObj : An object of class nb_graph.
%
% - newGraphObj : An object of class nb_graph.
% 
% Output:
%
% - copiedGraph : The copied graph as an nb_graph object.
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if not(isa(newGraphObj,'nb_graph_obj') || isa(newGraphObj,'nb_graph_adv'))
        error([mfilename ':: The added graph object must be of class nb_graph_obj or nb_graph_adv'])
    end

    for ii = 1:size(obj.graphObjects,2)
       
        if obj.graphObjects{ii} == oldGraphObj
            
            copiedGraph          = copy(newGraphObj);
            obj.graphObjects{ii} = copiedGraph;
            return
        end
        
    end
    
    error([mfilename ':: Resetting did not succeed. I.e. the oldGraphObj input was not found.'])
    
end

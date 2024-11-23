function remove(obj,graphToRemove)
% Syntax:
% 
% remove(obj,graphToRemove)
% 
% Description:
% 
% Remove specified graph object if found. Will give an error if not 
% found.
%
% Caution : When a nb_graph_obj or nb_graph_adv object is added to
%           an nb_graph_subplot object, it will be copied. So if 
%           you provided the same object as you added (as the 
%           graphToRemove), it will not be found and a error will 
%           occure.
%
% Input:
% 
% - obj           : An object of class nb_graph_subplot
% 
% - graphToRemove : An object of class nb_graph_obj or nb_graph_adv.
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    graphs = obj.graphObjects;
    for ii = 1:size(graphs,2)
        if graphs{ii} == graphToRemove
            obj.graphObjects = [graphs(1:ii - 1), graphs(ii + 1:end)];
            return
        end
    end
    
    error([mfilename ':: Could not remove the provided object. I.e. the graphToRemove input was not found.'])

end

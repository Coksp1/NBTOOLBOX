function remove(obj,identifier)
% Syntax:
%
% remove(obj,identifier)
%
% Description:
%
% Removes the graph stored with the identifier provided.
% 
% Input:
% 
% - obj        : An object of class nb_graph_package.
% 
% - identifier : A String with the identifier to the graph to 
%                remove.
% 
% Examples:
%
% obj.remove('Graph1')
%
% See also:
% nb_graph_package
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ind = ~strcmp(identifier,obj.identifiers);
    if all(ind)
        error([mfilename ':: Object with the identifier ' identifier ' does not exist.'])
    end
    obj.identifiers = obj.identifiers(ind);
    obj.graphs      = obj.graphs(ind);

end


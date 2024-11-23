function moveFirst(obj,identifier)
% Syntax:
%
% moveFirst(obj,identifier)
%
% Description:
%
% Moves the graph stored with the identifier provided first in the
% package.
% 
% Input:
% 
% - obj        : An object of class nb_graph_package.
% 
% - identifier : A String with the identifier to the graph to 
%                move last.
% 
% Examples:
%
% obj.moveFirst('Graph1')
%
% See also:
% nb_graph_package
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    ind      = strcmp(identifier,obj.identifiers);
    indMoved = find(ind,1);
    if isempty(indMoved)
        error([mfilename ':: Object with the identifier ' identifier ' does not exist.'])
    end
    graphToMove     = obj.graphs(indMoved);
    identifiersT    = obj.identifiers(~ind);
    graphsT         = obj.graphs(~ind);
    obj.identifiers = [identifier, identifiersT];
    obj.graphs      = [graphToMove, graphsT];
    
end

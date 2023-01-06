function moveLast(obj,identifier)
% Syntax:
%
% moveLast(obj,identifier)
%
% Description:
%
% Moves the graph stored with the identifier provided last in the
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
% obj.moveLast('Graph1')
%
% See also:
% nb_graph_package
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    ind             = strcmp(identifier,obj.identifiers);
    indMoved        = find(ind,1);
    if isempty(indMoved)
        error([mfilename ':: Object with the identifier ' identifier ' does not exist.'])
    end
    graphToMove     = obj.graphs(indMoved);
    obj.identifiers = obj.identifiers(~ind);
    obj.graphs      = obj.graphs(~ind);
    obj.identifiers = [obj.identifiers, identifier];
    obj.graphs      = [obj.graphs, graphToMove];
    
end

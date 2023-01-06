function add(obj,graph,identifier)
% Syntax:
% 
% add(obj,graph,identifier)
% 
% Description:
% 
% Add a graph to package. Must be an object of class nb_graph_adv or 
% nb_graph_subplot.
% 
% Input:
% 
% - obj        : An object of class nb_graph_package 
% 
% - graph      : An object of class nb_graph_adv or nb_graph_subplot
%
% - identifier : A string to link to the object. Used by the
%                reorder, remove and reset methods.
%
%                If given as empty, a default identifier is given.
%                I.e. 'GraphX'. Where X is the already added graph
%                + 1.
%
%                Caution : The identifier must be unique.
% 
% Examples:
%
% obj.add(nb_graph_advObj)
% obj.add(nb_graph_advObj,'Test')
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        identifier = '';
    end

    if isempty(identifier)
        identifier = ['Graph' int2str(size(obj.identifiers,2) + 1)];
    elseif ~ischar(identifier)
        error([mfilename ':: The provided identifier must be a string or empty.'])
    end
    
    if any(strcmpi(identifier,obj.identifiers))
        error([mfilename ':: The identifier ' identifier ' is already in use.'])
    end

    if isa(graph,'nb_graph_adv') || isa(graph,'nb_graph_subplot')
        obj.graphs      = [obj.graphs {graph}];
        obj.identifiers = [obj.identifiers identifier];
    else
        error([mfilename ':: It is only possible to add objects of class nb_graph_adv. Is ' class(graph)]) 
    end 

end

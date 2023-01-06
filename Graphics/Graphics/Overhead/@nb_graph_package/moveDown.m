function moveDown(obj,identifier)
% Syntax:
%
% moveDown(obj,identifier)
%
% Description:
%
% Moves the graph stored with the identifier provided 1 step down
% in the package. (If it is the last nothing will happend.)
% 
% Input:
% 
% - obj        : An object of class nb_graph_package.
% 
% - identifier : A String with the identifier to the graph to 
%                move down one step.
% 
% Examples:
%
% obj.moveDown('Graph1')
%
% See also:
% nb_graph_package
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    ind = find(strcmp(identifier,obj.identifiers),1);
    if isempty(ind)
        error([mfilename ':: Object with the identifier ' identifier ' does not exist.'])
    end
    
    if ind == size(obj.identifiers,2)
        return
    end
    
    % Switch the graphs
    tempGraph           = obj.graphs{ind};
    obj.graphs{ind}     = obj.graphs{ind + 1};
    obj.graphs{ind + 1} = tempGraph;

    % Switch the identifiers
    obj.identifiers{ind}     = obj.identifiers{ind + 1};
    obj.identifiers{ind + 1} = identifier;

end

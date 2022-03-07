function switchLocation(obj,identifier1,identifier2)
% Syntax:
%
% switchLocation(obj,identifier1,identifier2)
%
% Description:
%
% Moves the graph stored with the identifier provided last in the
% package.
% 
% Input:
% 
% - obj         : An object of class nb_graph_package.
% 
% - identifier1 : A String with the identifier to the graph to 
%                 switched.
% 
% - identifier2 : A String with the identifier to the graph to 
%                 switched.
%
% Examples:
%
% obj.switchLocation('Graph1','Graph2')
%
% See also:
% nb_graph_package
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ind1 = find(strcmp(identifier1,obj.identifiers),1);
    if isempty(ind1)
        error([mfilename ':: Object with the identifier ' identifier1 ' does not exist.'])
    end
    
    ind2 = find(strcmp(identifier2,obj.identifiers),1);
    if isempty(ind2)
        error([mfilename ':: Object with the identifier ' identifier2 ' does not exist.'])
    end
    
    % Switch the graphs
    tempGraph        = obj.graphs{ind1};
    obj.graphs{ind1} = obj.graphs{ind2};
    obj.graphs{ind2} = tempGraph;

    % Switch the identifiers
    obj.identifiers{ind1} = identifier2;
    obj.identifiers{ind2} = identifier1;
    
end

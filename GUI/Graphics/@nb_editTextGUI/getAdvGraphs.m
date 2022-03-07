function advGraphs = getAdvGraphs(graphStruct)
% Syntax:
%
% advGraphs = getAdvGraphs(graphs)
%
% Description:
%
% Part of DAG. Filters out graphs that is not nb_graph_adv.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    graphNames = fieldnames(graphStruct);
    graphCell  = struct2cell(graphStruct);
    ind        = cellfun('isclass',graphCell,'nb_graph_adv');
    ind2       = cellfun('isclass',graphCell,'nb_graph_subplot');
    advGraphs  = graphNames(ind | ind2);
    
end

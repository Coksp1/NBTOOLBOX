function types = getPlottedTypes(obj)
% Syntax:
% 
% types = getPlottedTypes(obj)
% 
% Description:
% 
% Get the plotted types of the graph
% 
% Input:
% 
% - obj      : An object of class nb_graph_cs
% 
% Output:
%
% - types    : As a cellstr
%
% Example:
% 
% types = obj.getPlottedTypes();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if strcmpi(obj.plotType,'scatter')
        types = [obj.scatterTypes, obj.scatterTypesRight];
    else
        types = obj.typesToPlot;
    end
    types = RemoveDuplicates(sort(types));

end

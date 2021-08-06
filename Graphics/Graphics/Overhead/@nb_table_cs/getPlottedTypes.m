function types = getPlottedTypes(obj)
% Syntax:
% 
% types = getPlottedTypes(obj)
% 
% Description:
% 
% Get the plotted types of the table
% 
% Input:
% 
% - obj      : An object of class nb_table_cs
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    types = obj.typesOfTable;
    types = RemoveDuplicates(sort(types));

end

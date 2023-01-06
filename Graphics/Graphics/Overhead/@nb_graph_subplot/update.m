function obj = update(obj,warningOff)
% Syntax:
% 
% obj = update(obj)
% 
% Description:
% 
% Update the data source of the figure(s)
% 
% Input:
% 
% - obj      : An object of class nb_graph_subplot
% 
% Output:
% 
% - obj      : An object of class nb_graph_subplot, where the data 
%              is updated for the different graph objects.
%     
% Examples:
%
% obj.update();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        warningOff = 'on';
    end

    for ii = 1:size(obj.graphObjects,2)
        obj.graphObjects{ii} = update(obj.graphObjects{ii},warningOff);
    end

end

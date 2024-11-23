function obj = deleteMethodCalls(obj,sourceNr,methodNrs)
% Syntax:
%
% obj = deleteMethodCalls(obj,c)
%
% Description:
%
% Delete some method calls of the object. The object needs to be updatable.
%
% Caution: To set method calls use setMethodCalls
%
% Caution: Call obj = update(obj) to interpret the changes made!
% 
% Input:
% 
% - obj       : An object of class nb_ts, nb_cs or nb_data
%
% - sourceNr  : The source index to delete the methods from
%
% - methodNrs : A index with the methods to delete.
% 
% Output:
%
% - obj       : An object of class nb_ts, nb_cs or nb_data 
%
% See also:
% setMethodCalls
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~obj.updateable
        error([mfilename ':: The object is not updateable'])
    end
    
    % Get the source of interest
    subL = obj.links.subLinks(sourceNr);

    % Find the index of operations to keep
    ind = ~ismember(1:length(subL.operations),methodNrs);
    
    % Delete the wanted operations
    subL.operations = subL.operations(ind);
    
    % Assign object the new method calls (operations)
    obj.links.subLinks(sourceNr) = subL;

end

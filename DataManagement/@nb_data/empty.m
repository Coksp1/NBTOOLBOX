function obj = empty(obj)
% Syntax:
%
% obj = empty(obj)
%
% Description: 
%
% Empty the existing nb_data object.
% 
% Input:
%
% - obj : An object of class nb_data
%
% Output:
%
% - obj : An empty nb_data object
%
% Examples:
% 
% obj = empty(obj)
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Give the data properties
    obj.variables = {};
    obj.data      = [];
    obj.dataNames = {};
    obj.startObs  = [];
    obj.endObs    = [];

    % Give the link properties
    obj.links       = struct([]);
    obj.updateable  = 0;

end

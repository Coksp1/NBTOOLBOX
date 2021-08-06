function obj = empty(obj)
% Syntax:
%
% obj = empty(obj)
%
% Description: 
%
% Empty the existing nb_ts object.
% 
% Input:
%
% - obj : An object of class nb_ts
%
% Output:
%
% - obj : An empty nb_ts object
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
    obj.frequency = [];
    obj.startDate = nb_date;
    obj.endDate   = nb_date;
    
    % Give the link properties
    obj.links       = struct([]);
    obj.updateable  = 0;

end

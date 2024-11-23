function obj = empty(obj)
% Syntax:
%
% obj = empty(obj)
%
% Description:
%
% Empty the nb_bd object 
% 
% Input:
% 
% - obj : An object of class nb_bd
% 
% Output:
% 
% - obj : An empty nb_bd object
% 
% Examples:
%
% obj = empty(obj);
% 
% Written by Per Bjarne Bye 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen


    % Give the data properties
    obj.variables = {};
    obj.data      = [];
    obj.dataNames = {};
    obj.frequency = [];
    obj.startDate = nb_date;
    obj.endDate   = nb_date;
    obj.locations = [];
    obj.indicator = [];
    obj.ignorenan = [];
    
    % Give the link properties
    obj.links       = struct([]);
    obj.updateable  = 0;

end

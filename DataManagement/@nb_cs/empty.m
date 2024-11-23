function obj = empty(obj)
% Syntax:
%
% obj = empty(obj)
%
% Description:
%
% Empty the nb_cs object 
% 
% Input:
% 
% - obj : An object of class nb_cs
% 
% Output:
% 
% - obj : An empty nb_cs object
% 
% Examples:
%
% obj = nb_cs([2,2],'test',{'First'},{'Var1','Var2'});
% obj = empty(obj);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Set the data properties
    obj.variables = {};
    obj.data      = [];
    obj.dataNames = {};
    obj.types     = {};
    
    % Give the link properties
    obj.links       = struct([]);
    obj.updateable  = 0;

end

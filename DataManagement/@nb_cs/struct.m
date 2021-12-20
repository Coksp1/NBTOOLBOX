function s = struct(obj)
% Syntax:
%
% s = struct(obj)
%
% Description:
%
% Object to struct.
% 
% Input:
% 
% - obj : An nb_cs object.
% 
% Output:
% 
% - s  : A structure representing an nb_cs object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    s = struct('class',         'nb_cs',...
               'data',          obj.data,...
               'dataNames',     {obj.dataNames},...
               'types',         {obj.types},...
               'userData',      obj.userData,...
               'variables',     {obj.variables},...
               'links',         obj.links,...
               'localVariables',obj.localVariables,...
               'sorted',        obj.sorted,...
               'updateable',    obj.updateable);

end

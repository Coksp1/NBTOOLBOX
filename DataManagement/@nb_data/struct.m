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
% - obj : An nb_data object.
% 
% Output:
% 
% - s  : A structure representing an nb_data object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    s = struct('class',         'nb_data',...
               'data',          obj.data,...
               'dataNames',     {obj.dataNames},...
               'endObs',        obj.endObs,...
               'startObs',      obj.startObs,...
               'userData',      obj.userData,...
               'variables',     {obj.variables},...
               'links',         obj.links,...
               'localVariables',obj.localVariables,...
               'sorted',        obj.sorted,...
               'updateable',    obj.updateable);

end

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
% - obj : An nb_cell object.
% 
% Output:
% 
% - s  : A structure representing an nb_cell object.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    s = struct('class',         'nb_cell',...
               'data',          {obj.cdata},...
               'dataNames',     {obj.dataNames},...
               'userData',      obj.userData,...
               'links',         obj.links,...
               'localVariables',obj.localVariables,...
               'sorted',        obj.sorted,...
               'updateable',    obj.updateable);

end

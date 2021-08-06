function ret = isBoolean(obj)
% Syntax:
%
% ret = isBoolean(obj)
%
% Description:
%
% Check if the data of the nb_dataSource object is of class logical 
% (boolean, i.e. true or false).
% 
% Input:
% 
% - obj : An object of class nb_dataSource.
% 
% Output:
% 
% - ret : true or false.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    ret = isa(obj.data,'logical');

end

function cl = getClassOfData(obj)
% Syntax:
%
% cl = getClassOfData(obj)
%
% Description:
%
% Get the class of the data stored by the object.
% 
% Input:
% 
% - obj : An object of class nb_dataSource.
% 
% Output:
% 
% - cl : Name of the class that the data of the object is stored as.
%
% See also:
% nb_dataSource.isDistribution, nb_dataSource.isDouble,
% nb_dataSource.isBoolean
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    cl = class(obj.data);

end

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
% - obj : An object of class nb_math_ts.
% 
% Output:
% 
% - cl : Name of the class that the data of the object is stored as.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    cl = class(obj.data);

end

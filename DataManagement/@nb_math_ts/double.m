function dataOfObject = double(obj)
% Syntax:
%
% dataOfObject = double(obj)
%
% Description:
%
% Get the data of the object as a double matrix
% 
% Input:
% 
% - obj          : An object of class nb_math_ts
%
% Output:
%
% - dataOfObject : The data of the nb_math_ts object
%
% Examples:
%
% dataOfObject = double(obj)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    dataOfObject = obj.data;

end

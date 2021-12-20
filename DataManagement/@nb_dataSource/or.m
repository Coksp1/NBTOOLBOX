function a = or(a,b)
% Syntax:
%
% a = or(a,b)
%
% Description:
%
% The and operator (|).
%
% Caution: The objects must have the same dimension and variables!
%
% Input:
% 
% - a : An object of class nb_dataSource.
% 
% - b : An object of class nb_dataSource, but must be of same
%       subclass as a!
% 
% Output:
% 
% - a : An object of class nb_dataSource. Where the or operator 
%       has evaluated all the data elements of the object.
%       The data will be a logical matrix. 
%
% Examples:
%
% a = a | b;
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    a = callLogicalFunc(a,b,@or);
    
end

function a = ne(a,b)
% Syntax:
%
% a = ne(a,b)
%
% Description:
% 
% Test if the one object is not equal to (~=) the other object elemetswise   
% and return a nb_dataSource object where each element are 1 if true,
% otherwise 0. 
%
% Caution: The objects must have the same dimension and variables!
% 
% It is also possible to test each element of an object to a scalar 
% number.
%
% Input:
% 
% - a : An object of class nb_dataSource or a scalar number.
% 
% - b : An object of class nb_dataSource, but must be of same
%       subclass as a, or a scalar number.
% 
% Output:
% 
% - a : An nb_dataSource object where the data element are logical.  
%             
% Examples:
%
% obj = a ~= b;
% obj = 2 ~= b;
% obj = a ~= 2;
% 
% Written by Kenneth S. Paulsen 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    a = callRelationFunc(a,b,@ne);

end

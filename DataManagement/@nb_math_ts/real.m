function obj = real(obj)
% Syntax:
%
% obj = real(obj)
%
% Description:
%
% real(obj) returns the real part of the elements in the nb_math_ts object
% 
% Input:
% 
% - obj           : An object of class nb_math_ts
% 
% Output:
% 
% - obj           : An object of class nb_math_ts where the data are the   
%                   real part of the elements of the original object.
% 
% Examples:
% 
% obj = real(obj);
%
% Written by Andreas Haga Raavand

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = real(obj.data);

end

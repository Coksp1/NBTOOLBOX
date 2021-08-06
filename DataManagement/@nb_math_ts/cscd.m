function obj = cscd(obj)
% Syntax:
%
% obj = cscd(obj)
%
% Description:
%
% cscd(obj) is the cosecant of the elements of obj, expressed in degrees.
% 
% Input:
% 
% - obj       : An object of class nb_math_ts
% 
% Output: 
% 
% - obj       : An object of class nb_math_ts
% 
% Examples:
%
% out = cscd(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = cscd(obj.data);

    
end

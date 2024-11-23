function ret = isscalar(obj) %#ok
% Syntax:
%
% ret = isscalar(obj)
%
% Description:
%
% Test if a nb_ts, nb_cs or nb_data object is a scalar. Will always return  
% 0, as an object of class nb_ts, nb_cs or nb_data is not a scalar.
% 
% Input:
% 
% - obj       : An object of class nb_ts, nb_cs or nb_data
% 
% Output:
% 
% - ret       : false
% 
% Examples:
%
% 0 = isscalar(obj);
% 
% Written by Kenneth S. Paulsen  

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    ret = false;

end

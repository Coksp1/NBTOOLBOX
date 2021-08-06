function obj = isfinite(obj)
% Syntax:
%
% obj = isfinite(obj)
%
% Description:
%
% Test if each element of a nb_ts, nb_cs or nb_data object is finite. 
% 
% Caution : Non-updateable operation.
%
% Input:
% 
% - obj  : An object of class nb_ts, nb_cs or nb_data
% 
% Output:
% 
% - obj  : The object with data as logical. 1 if an element is 
%          finite, otherwise 0.
% 
% Examples:
% 
% obj = isfinite(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = isfinite(obj.data);

end

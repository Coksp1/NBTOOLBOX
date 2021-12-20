function obj = isnan(obj)
% Syntax:
%
% obj = isnan(obj)
%
% Description:
%
% Test if each element of an nb_ts, nb_cs or nb_data object is nan. 
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
%          nan, otherwise 0.
% 
% Examples:
% 
% obj = isnan(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = isnan(obj.data);

end

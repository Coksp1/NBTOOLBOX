function ret = isempty(obj)
% Syntax:
%
% ret = isempty(obj)
%
% Description:
%
% Test if a nb_ts, nb_cs or nb_data object is empty. Return 1 if true, 
% otherwise 0.
% 
% Input:
% 
% - obj       : An object of class nb_ts, nb_cs or nb_data
% 
% Output:
% 
% - ret       : True (1) if the series isempty, false (0) if not
% 
% Examples:
%
% ret = isempty(obj);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ret = isempty(obj.data);

end

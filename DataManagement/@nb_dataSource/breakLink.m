function obj = breakLink(obj)
% Syntax:
%
% obj = breakLink(obj)
%
% Description:
%
% Break link to source
% 
% Input:
% 
% - obj : An object of class nb_ts, nb_cs or nb_data
% 
% Output:
% 
% - obj : An object of class nb_ts, nb_cs or nb_data 
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    obj.links      = struct([]);
    obj.updateable = 0;

end

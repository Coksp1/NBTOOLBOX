function obj = stopSorting(obj)
% Syntax:
%
% obj = stopSorting(obj)
%
% Description:
%
% Stop sorting of variables.
% 
% Input:
% 
% - obj : An object of class nb_ts, nb_cs or nb_data.
%            
% Output:
% 
% - obj : An object of class nb_ts, nb_cs or nb_data where sorting is
%         turned of.
% 
% Example:
% 
% obj = obj.addPrefix('NEMO.');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.sorted = false;

end

function ret = isDouble(obj)
% Syntax:
%
% ret = isDouble(obj)
%
% Description:
%
% Check if the data of the nb_dataSource object is of class double 
% (numeric)
% 
% Input:
% 
% - obj : An object of class nb_dataSource.
% 
% Output:
% 
% - ret : true or false.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ret = isa(obj.data,'double');

end

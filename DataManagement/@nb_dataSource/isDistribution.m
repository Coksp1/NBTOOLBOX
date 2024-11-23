function ret = isDistribution(obj)
% Syntax:
%
% ret = isDistribution(obj)
%
% Description:
%
% Check if the data of the nb_dataSource object is of class nb_distribution
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    ret = isa(obj.data,'nb_distribution');

end

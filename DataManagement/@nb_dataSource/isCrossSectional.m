function ret = isCrossSectional(obj) 
% Syntax:
%
% ret = isCrossSectional(obj)
%
% Description:
%
% Test if this object is a cross sectional data object.
% 
% Input:
% 
% - obj : An object of class nb_dataSource
% 
% Output:
% 
% - ret : true if object is of class nb_cs, otherwise false.
%      
% Written by Kenneth S. Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ret = isa(obj,'nb_cs'); 

end

function obj = floor(obj)
% Syntax:
%
% obj = floor(obj)
%
% Description:
%
% floor(obj) rounds the data elements of obj to the nearest integers
% towards minus infinity
% 
% Input:
% 
% - obj       : An object of class nb_data
% 
% Output: 
% 
% - obj       : An object of class nb_data
% 
% Examples:
%
% out = floor(in);
% 
% Written by Andreas Haga Raavand  

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = floor(obj.data);

end

function obj = ceil(obj)
% Syntax:
%
% obj = ceil(obj)
%
% Description:
%
% ceil(obj) rounds the elements of obj to the nearest integers
% towards infinity.
% 
% Input:
% 
% - obj       : An object of class nb_math_ts
% 
% Output: 
% 
% - obj       : An object of class nb_math_ts
% 
% Examples:
%
% out = ceil(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = ceil(obj.data);

end

function obj =   cot(obj)
% Syntax:
%
% obj = cot(obj)
%
% Description:
%
% Take cotangent of the data stored in the nb_ts object
% 
% Input:
% 
% - obj           : An object of class nb_ts
% 
% Output:
% 
% - obj           : An object of class nb_ts where the data are on 
%                   cot.
% 
% Examples:
% 
% obj = cot(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = cot(obj.data);
    

end

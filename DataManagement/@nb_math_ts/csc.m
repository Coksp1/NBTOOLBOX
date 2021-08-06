function obj =   csc(obj)
% Syntax:
%
% obj = csc(obj)
%
% Description:
%
% Take csc of the data stored in the nb_ts object
% 
% Input:
% 
% - obj           : An object of class nb_ts
% 
% Output:
% 
% - obj           : An object of class nb_ts where the data has been transformed
% 
% Examples:
% 
% obj = csc(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = csc(obj.data);
    
end

function obj =   cos(obj)
% Syntax:
%
% obj = cos(obj)
%
% Description:
%
% Take cos of the data stored in the nb_ts object
% 
% Input:
% 
% - obj           : An object of class nb_ts
% 
% Output:
% 
% - obj           : An object of class nb_ts where the data are on 
%                   cos.
% 
% Examples:
% 
% obj = cos(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = cos(obj.data);
    
end

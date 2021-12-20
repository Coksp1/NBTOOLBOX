function obj =  sec(obj)
% Syntax:
%
% obj = sec(obj)
%
% Description:
%
% Take sec of the data stored in the nb_ts object
% 
% Input:
% 
% - obj           : An object of class nb_ts
% 
% Output:
% 
% - obj           : An object of class nb_ts where the data are on 
%                   sec.
% 
% Examples:
% 
% obj = sec(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = sec(obj.data);
end

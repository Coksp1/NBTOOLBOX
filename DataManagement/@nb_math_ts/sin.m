function obj =   sin(obj)
% Syntax:
%
% obj = sin(obj)
%
% Description:
%
% Take sin of the data stored in the nb_ts object
% 
% Input:
% 
% - obj           : An object of class nb_ts
% 
% Output:
% 
% - obj           : An object of class nb_ts where the data are on 
%                   sin.
% 
% Examples:
% 
% obj = sin(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = sin(obj.data);

end

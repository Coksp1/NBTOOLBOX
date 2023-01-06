function t = struct2table(obj,varargin)
% Syntax:
%
% t = struct2table(obj,varargin)
%
% Description:
%
% Convert the nb_struct object into a table.
% 
% Input:
% 
% - obj : An object of class nb_struct.
% 
% - Otherwise the same inputs(s) as the struct2table function of a normal 
%   MATLAB struct.
%
% Output:
% 
% - Same output(s) as the struct2table function of a normal MATLAB struct.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    t = struct2table(obj.s,varargin{:}); 

end

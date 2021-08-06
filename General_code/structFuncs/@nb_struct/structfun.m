function varargout = structfun(obj,varargin)
% Syntax:
%
% varargout = structfun(obj,varargin)
%
% Description:
%
% Evaluate a function on the nb_struct object. For more see the structfun
% method of a MATLAB struct,
% 
% Input:
% 
% - obj : An object of class nb_struct.
% 
% - Otherwise the same inputs(s) as the structfun function of a normal 
%   MATLAB struct.
%
% Output:
% 
% - Same output(s) as the structfun function of a normal MATLAB struct.
%
% Written by Kenneth Sæterhagen Paulsen   

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [varargout{1:nargout}] = structfun(obj.s,varargin{:}); 

end

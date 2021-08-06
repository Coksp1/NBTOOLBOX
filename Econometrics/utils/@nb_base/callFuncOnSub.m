function obj = callFuncOnSub(obj,func,varargin)
% Syntax:
%
% obj = callFuncOnSub(obj,func,varargin)
%
% See also:
% nb_term.generalFunc
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    obj = nb_equation(func,vertcat(obj,varargin{:}));
    
end

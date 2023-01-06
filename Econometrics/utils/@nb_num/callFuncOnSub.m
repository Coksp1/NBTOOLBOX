function obj = callFuncOnSub(obj,func,varargin)
% Syntax:
%
% obj = callFuncOnSub(obj,func,varargin)
%
% See also:
% nb_term.generalFunc
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    all = vertcat(obj,varargin{:});
    if isa(all,'nb_num')
        % E.g. normpdf(0.5,0,1)
        funcH     = str2func(func);
        inputs    = {all.value};
        obj.value = funcH(inputs{:});
    else
        % E.g. normpdf(0.5,x1,1)
        obj = nb_equation(func,all);
    end
    
end

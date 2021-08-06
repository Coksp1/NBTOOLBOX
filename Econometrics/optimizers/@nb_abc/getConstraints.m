function constrFunc = getConstraints(obj)
% Syntax:
%
% constrFunc = getConstraints(obj)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if obj.hasConstraints
        constrFunc = @(x)nb_abc.combineConstraints(x,obj.constraints,obj.options.tolerance);
    else
        constrFunc = [];
    end
    
end

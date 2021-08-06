function constrFunc = getConstraints(obj)
% Syntax:
%
% constrFunc = getConstraints(obj)
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if obj.hasConstraints
        constrFunc = @(x)nb_abc.combineConstraints(x,obj.constraints,obj.options.tolerance);
    else
        constrFunc = [];
    end
    
end

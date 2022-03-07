function position = nb_getInUnits(object, property, units)
% Syntax:
%
% position = nb_getInUnits(object, property, units)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    originalUnits = get(object, 'Units');
    set(object, 'Units', units);
    position = get(object, property);
    if iscell(originalUnits)
        originalUnits = originalUnits{1};
    end
    set(object, 'Units', originalUnits);
end

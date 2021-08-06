function position = nb_getInUnits(object, property, units)
% Syntax:
%
% position = nb_getInUnits(object, property, units)
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    originalUnits = get(object, 'Units');
    set(object, 'Units', units);
    position = get(object, property);
    if iscell(originalUnits)
        originalUnits = originalUnits{1};
    end
    set(object, 'Units', originalUnits);
end

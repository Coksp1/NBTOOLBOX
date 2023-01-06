function nb_setInUnits(object, property, value, units)
% Syntax:
%
% nb_setInUnits(object, property, value, units)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    originalUnits = get(object, 'Units');
    set(object, 'Units', units);
    set(object, property, value);
    set(object, 'Units', originalUnits);
    
end

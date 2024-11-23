function position = nb_paddingPosition(parent, points)
% Syntax:
%
% position = nb_paddingPosition(parent, points)
%
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    padding  = points * nb_unitsRatio('Points', 'Normalized', parent);
    position = [padding(1), padding(2), 1 - 2*padding(1), 1 - 2*padding(2)];
    
end

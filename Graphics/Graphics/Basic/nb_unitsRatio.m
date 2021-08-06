function ratio = nb_unitsRatio(from, to, parent)
% Description:
%
% Calculate ratio between different units
% 
% Examples:
%
% nb_unitsRatio('Characters', 'Normalized', axes);
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    positionInToUnits = nb_conditional(...
        strcmpi(to, 'normalized'), ...
        [0 0 1 1], ...
        nb_getInUnits(parent, 'Position', to));
    
    positionInFromUnits = nb_conditional(...
        strcmpi(from, 'normalized'), ...
        [0 0 1 1], ...
        nb_getInUnits(parent, 'Position', from));
    
    ratio = positionInToUnits(3:4) ./ positionInFromUnits(3:4);
    
end

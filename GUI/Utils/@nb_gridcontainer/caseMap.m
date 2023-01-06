function caseMap = caseMap(values)
% Syntax:
%
% caseMap = nb_gridcontainer.caseMap(values)
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    keys    = lower(values);
    m       = transpose([keys, values]);
    caseMap = struct(m{:});
    
end

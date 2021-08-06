function Y = getStartingValues(obj,inputs)
% Syntax:
%
% Y = nb_perfectForesight.getStartingValues(obj,inputs)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    switch lower(inputs.startingValues)
        case 'steady_state'
            ss = obj.solution.ss;
            Y  = ss(:,ones(1,inputs.periods));
            Y  = Y(:);
        otherwise
            error([mfilename ':: Unsupported input given to the startingValue input; ' inputs.startingValues])
    end
    
end

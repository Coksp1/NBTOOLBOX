function deterministic = getDeterministicVariables(exo)
% Syntax:
%
% deterministic = nb_forecast.getDeterministicVariables(exo)
%
% Description:
%
% Get the deterministic exogenous variables.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    ind           = strncmpi('covidDummy',exo,10);
    indT          = strncmpi('timeDummy',exo,9);
    deterministic = [{'constant','time-trend','easterDummy'}, exo(ind), exo(indT)];
    
end

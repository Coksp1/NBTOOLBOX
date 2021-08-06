function deterministic = getDeterministicVariables(exo)
% Syntax:
%
% deterministic = nb_forecast.getDeterministicVariables(exo)
%
% Description:
%
% Get the deterministic exogenous variables.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    ind           = strncmpi('covidDummy',exo,10);
    indT          = strncmpi('timeDummy',exo,9);
    deterministic = [{'constant','time-trend','easterDummy'}, exo(ind), exo(indT)];
    
end

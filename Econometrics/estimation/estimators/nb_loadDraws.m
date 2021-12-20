function posterior = nb_loadDraws(pathToLoad)
% Syntax:
%
% posterior = nb_loadDraws(pathToLoad)
%
% Description:
%
% Load posterior draws from file.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Load posterior draws of main model 
    draws     = load(pathToLoad);
    posterior = draws.posterior;

end

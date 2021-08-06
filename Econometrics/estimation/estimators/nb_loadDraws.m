function posterior = nb_loadDraws(pathToLoad)
% Syntax:
%
% posterior = nb_loadDraws(pathToLoad)
%
% Description:
%
% Load posterior draws from file.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Load posterior draws of main model 
    draws     = load(pathToLoad);
    posterior = draws.posterior;

end

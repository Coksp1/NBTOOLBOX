function s = nb_availablePoolSize()
% Syntax:
%
% s = nb_availablePoolSize()
%
% Description:
%
% Get number of available workers when running in parallel.
% 
% Output:
% 
% - s : An interger with the number of workers. 
%
%       Caution: If the environment variable clusterProfile is set, then
%                inf is returned, as in this case the number of cores
%                used cannot be set anyway.
%
% See also:
% nb_openPool, nb_closePool, nb_poolSize
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    clusterProfile = getenv('clusterProfile');
    if ~isempty(clusterProfile)
        s = inf;
        return;
    end
    s = getenv('NUMBER_OF_PROCESSORS');
    if ischar(s)
        s = str2double(s);
    end
    
end

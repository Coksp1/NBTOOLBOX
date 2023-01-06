function s = nb_poolSize()
% Syntax:
%
% s = nb_poolSize()
%
% Description:
%
% Get number of active workers when running in parallel.
% 
% Output:
% 
% - s : An interger with the number of workers.
%
% See also:
% nb_openPool, nb_closePool, nb_availablePoolSize
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if verLessThan('matlab','8.2')
        s = matlabpool('size');
    else
        poolobj = gcp('nocreate');
        if isempty(poolobj)
            s = 0;
        else
            s = poolobj.NumWorkers; 
        end
    end

end

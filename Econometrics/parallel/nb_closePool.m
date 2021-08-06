function nb_closePool(ret)
% Syntax:
%
% nb_closePool(ret)
%
% Description:
%
% Close a parallel session. Invariante to MATLAB version.
%
% Input:
%
% - ret : 1 if the matlabpool should be close otherwise 0. Default 
%         is 1.
% 
% See also:
% nb_openPool, nb_poolSize, nb_availablePoolSize
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 1
        ret = true;
    end

    if verLessThan('matlab','8.2')
        if ret == 1
            matlabpool('close','force');
        end
    else
        if ret == 1
            poolobj = gcp('nocreate');
            if ~isempty(poolobj)
                delete(poolobj);
            end
        end
    end

end

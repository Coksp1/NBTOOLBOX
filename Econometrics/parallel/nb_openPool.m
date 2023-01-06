function ret = nb_openPool(cores)
% Syntax:
%
% ret = nb_openPool()       : Uses all cores
% ret = nb_openPool(cores)  : Uses the number of selected cores
%
% Description:
%
% Open up a parallel session if not already open.
%
% Caution: To open a cluster pool set the environtment variable 
%          clusterProfile; setenv('clusterProfile','yourProfileName')
%
% Input:
%
% - cores : Number of cores to open, as an integer. Default is available.
%
% Output:
%
% - ret   : 1 if matlabpool was opened, else 0.
%
% See also:
% nb_closePool, nb_poolSize, nb_availablePoolSize
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 1
        cores = [];
    end

    ret = 0;
    if verLessThan('matlab','8.2')
        
        if ~isempty(cores)
            if matlabpool('size') ~= cores
                if matlabpool('size') ~= 0
                    nb_closePool(true); % Close old parallel session
                end
                matlabpool('open',cores);
                ret = 1;
            end 
        else
            if matlabpool('size') == 0 
                matlabpool('open');
                ret = 1;
            end
        end
        
    else
        
        clusterProfile = getenv('clusterProfile');
        poolobj        = gcp('nocreate');
        if isempty(clusterProfile)
        
            if ~isempty(cores)
                if isempty(poolobj)
                    parpool(cores);
                    ret = 1;
                else
                    if poolobj.NumWorkers ~= cores
                        nb_closePool(true); % Close old parallel session
                        parpool(cores);
                        ret = 1;
                    end
                end
            else
                if isempty(poolobj)
                    parpool;
                    ret = 1;
                end
            end
            
        else
            
            if ~isempty(cores)
                warning('nb_openPool:CannotSetCoresWhenCluster',...
                    ['The number of cores cannot be set when using a ',...
                    'cluster profile. The profile sets this.'])
            end
            if isempty(poolobj)
                p = parcluster(clusterProfile);
                parpool(p);
                ret = 1;
            end
            
        end
        
    end

end

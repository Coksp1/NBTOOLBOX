function res = geweke(obj,chain,type)
% Syntax:
%
% res = geweke(obj)
% res = geweke(obj,chain,type)
%
% Description:
%
% Geweke (1992) test. This test split sample into two parts. The first 
% 10% and the last 50%. If the chain is at stationarity, the means of two 
% samples should be equal. The null hypothesis is that the subsamples has 
% the same mean.
% 
% Input:
% 
% - obj   : A scalar nb_model_sampling object.
%
% - chain : Give the chain to test. If [] all chains are tested (default).
% 
% - type  : 'posterior' to test posterior draws (default) or 'updated' 
%           to test updated prior draws.  
% 
% Output:
% 
% - res : A 2 x nParam x nChains nb_cs with the difference in mean 
%         statistics ('statistic') and p-values ('P-value').
%
% See also:
% nb_mcmc.geweke, nb_model_sampling.sample
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'posterior';
        if nargin < 2
            chain = [];
        end
    end

    if numel(obj) > 1
        error([mfilename ':: This method only handles scalar ' class(obj) '.'])
    end
    
    % Get names of estimated parameters
    paramEst = obj.options.prior(:,1)';
    
    % Get the sampled output
    if strcmpi(type,'updated')
        if ~isa(obj,'nb_model_sampling')
            error([mfilename ':: Error, no sampling of the updated priors can be done for this model.'])
        end
        if isempty(obj.systemPriorPath)
            error([mfilename ':: Error, no sampling of the updated priors has been done.'])
        end
        output = nb_loadDraws(obj.systemPriorPath);
    else
        if ~isfield(obj.estOptions,'pathToSave')
            error([mfilename ':: Error no sampling of the posteriors has been done.'])
        end
        posterior = nb_loadDraws(obj.estOptions.pathToSave);
        if ~isfield(posterior,'output')
            error([mfilename ':: No sampling is done.'])
        elseif nb_isempty(posterior.output)
            error([mfilename ':: No sampling is done.'])
        end
        output = posterior.output;
    end
    
    % Do the test
    if isempty(chain)
        
        beta    = nb_mcmc.loadBetaFromOuput(output,chain);
        nChains = numel(output);
        res     = nan(2,length(paramEst),nChains);
        for cc = 1:nChains
            [res(1,:,cc),res(2,:,cc)] = nb_mcmc.geweke(beta(:,:,cc));
        end
        chains = nb_appendIndexes('Geweke test (chain',1:nChains)';
        chains = strcat(chains,')');
        res    = nb_cs(res,chains,{'Statistic','P-value'},paramEst);
        
    else
        
        if ~nb_isScalarInteger(chain)
            error([mfilename ':: chain must be an integer.'])
        end
        if chain < 0 
            error([mfilename ':: chain must be positive'])
        end
        if chain > numel(output) 
            error([mfilename ':: chain must be less than the number of sampled chains (' int2str(numel(output)) ').'])
        end
        beta  = nb_mcmc.loadBetaFromOuput(output,chain);
        [z,p] = nb_mcmc.geweke(beta);
        res   = nb_cs([z;p],'Geweke test',{'Statistic','P-value'},paramEst);
        
    end
    
end

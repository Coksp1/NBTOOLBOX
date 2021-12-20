function beta = loadBetaFromOuput(output,chain,type)
% Syntax:
%
% beta = nb_mcmc.loadBetaFromOuput(output,chain)
%
% Description:
%
% Load the sampled draws of the parameters from files.
% 
% Input:
% 
% - output : The output struct on of the samplers of the nb_mcmc package.
% 
% - chain  : Sepcify the loaded chain. If empty all chains are loaded.
% 
% Output:
% 
% - beta   : The sampled parameters as a nDraws x nPar x nChains double.
%
% See also:
% nb_mcmc.mhSampler, nb_mcmc.nutSampler
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'double';
        if nargin < 2
            chain = [];
        end
    end
    if ~isempty(chain)
       output = output(chain); 
    end
    nChains       = numel(output);
    [nDraws,nPar] = size(output(1).beta);
    if strcmpi(type,'cell')
        
        if nDraws == 0

            beta    = cell(1,nChains); 
            nDraws  = output(1).draws;
            storeAt = output(1).storeAt;
            nPar    = size(output(1).sigma,1);
            betaC   = nan(nDraws,nPar);
            for ii = 1:nChains
                files = output(ii).files;
                ub    = unique([storeAt:storeAt:nDraws,nDraws]);
                lb    = [1, ub(1:end-1) + 1];
                for jj = 1:length(files)
                   loaded                 = load(files{jj},'beta');
                   betaC(lb(jj):ub(jj),:) = loaded.beta;
                end
                beta{ii} = betaC;
            end

        else

            beta = cell(1,nChains);   
            for ii = 1:nChains
                beta{ii} = output(ii).beta;
            end

        end
        
    else
    
        if nDraws == 0

            nDraws  = output(1).draws;
            storeAt = output(1).storeAt;
            nPar    = size(output(1).sigma,1);
            beta    = nan(nDraws,nPar,nChains);
            for ii = 1:nChains
                files = output(ii).files;
                ub    = unique([storeAt:storeAt:nDraws,nDraws]);
                lb    = [1, ub(1:end-1) + 1];
                for jj = 1:length(files)
                   loaded                   = load(files{jj},'beta');
                   beta(lb(jj):ub(jj),:,ii) = loaded.beta;
                end
            end

        else

            beta = nan(nDraws,nPar,nChains);   
            for ii = 1:nChains
                beta(:,:,ii) = output(ii).beta;
            end

        end
        
    end

end

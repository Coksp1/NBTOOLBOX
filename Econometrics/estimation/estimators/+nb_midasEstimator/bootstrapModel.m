function [betaDraws,sigmaDraws,estOpt] = bootstrapModel(~,options,results,method,draws,iter,forceNewDraws)
% Syntax:
%
% [betaDraws,sigmaDraws,estOpt] = nb_midasEstimator.bootstrapModel(model,...
%                         options,results,method,draws,iter,forceNewDraws)
%
% Description:
%
% Bootstrap MIDAS model.
%
% Caution: The options struct is assumed to already be index by iter!
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 7
        forceNewDraws = true;
        if nargin < 6
            iter = 'end';
        end
    end
    if strcmpi(iter,'end')
        iter = size(results.beta,3);
    end
    
    % Some options that we reset
    estOpt   = options;
    estOpt.recursive_estim = 0;
    
    % Preallocation
    betaDraws  = nan(size(results.beta,1),size(results.beta,2),draws);
    sigmaDraws = zeros(size(results.beta,2),size(results.beta,2),draws);
    
    if ~forceNewDraws
        % Use already bootstrapped parameter draws
        madeDraws = size(results.betaD,3);
        if madeDraws > draws
            madeDraws = draws;
        end
        betaDraws(:,:,1:madeDraws)  = results.betaD(:,:,1:madeDraws,iter);
        sigmaDraws(:,:,1:madeDraws) = results.sigmaD(:,:,1:madeDraws,iter);
        draws                       = draws - madeDraws;
        if draws == 0
            return
        end 
        start = madeDraws + 1;
    else
        start = 1;
    end
    
    % Get regressors
    [~,indY] = ismember(options.dependent(1),options.dataVariables);
    y        = options.data(options.mappingDep,indY);
    [~,indX] = ismember(options.exogenous,options.dataVariables);
    nExo     = length(options.exogenous);
    x        = nan(size(y,1),nExo);
    for ii = 1:nExo
        x(:,ii) = options.data(options.mappingExo(:,ii),indX(ii));
    end
    if options.recursive_estim
        % When recursive forecast is produced we need to cut the sample
        % according to the samle used at this recursion!
        T = options.recursive_estim_start_ind_low - (options.start_low_in_low - 1) + (iter - 1);
        y = y(1:T,:);
        x = x(1:T,:);
    end
    
    % Bootstrap MIDAS model
    [~,~,~,~,~,~,betaDraws(:,:,start:end),sigmaDraws(:,:,start:end)] = ...
        nb_midasFunc(y,x,options.constant,options.AR,options.algorithm,...
        options.nStep,'h',options.nExo,options.nLags+1,'draws',draws,...
        'polyLags',options.polyLags);
    
    
end

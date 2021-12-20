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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
    beta       = results.beta(:,:,iter);
    residual   = results.residual(:,:,iter);
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
        start = madeDraws;
    else
        start = 0;
    end
    
    % Get regressors
    [~,indX] = ismember(options.exogenous,options.dataVariables);
    x        = options.data(options.start_low:options.increment:options.estim_end_ind,indX); 
    [~,indY] = ismember(options.dependent(1),options.dataVariables);
    y        = options.data(options.start_low:options.increment:options.estim_end_ind,indY); 
    
    if options.nStep > 1
        Y = [y,nb_mlead(y,options.nStep-1)];
    else 
        Y = y;
    end
    
    % Do the bootstrapping
    constant = options.constant;
    AR       = options.AR;
    %======================================================================
    if strcmpi(options.algorithm,'unrestricted')
    %======================================================================
    
        if AR
           yLag = lag(y);
           yLag = yLag(2:end);
           Y    = Y(2:end,:);
           x    = x(2:end,:);
        end
        
        numCoeff = size(results.beta,1); 
        for ii = 1:options.nStep
            
            if AR
                if ii == 1
                    xi = [yLag,x];
                else
                    xi = [Y(1:end-ii+1,ii-1),x(1:end-ii+1,:)];
                end
            else
                xi = x(1:end-ii+1,:);
            end
            
            res      = residual(:,ii);
            isNaN    = ~isnan(res);
            indFirst = find(isNaN,1);
            indLast  = find(isNaN,1,'last');
            res      = res(indFirst:indLast);
            xiTemp   = xi(indFirst:indLast,:);
            ysim     = nb_midasBootstrap(beta(:,ii),res,xiTemp,...
                          constant,[],options.nExo,AR,draws,method);
            for dd = 1:draws
                [betaDraws(:,ii,start+dd),~,~,~,resid] = nb_ols(ysim(:,dd),xiTemp,constant,false);
                sigmaDraws(ii,ii,start+dd)             = resid'*resid/(size(resid,1) + 1 - numCoeff);
            end
            
        end
        
    %======================================================================    
    else % Restricted
    %======================================================================
        
        nSteps = options.nStep;
        nExo   = options.nExo;
        switch lower(options.algorithm)
        
            case 'almon'

                func    = @(x,y)nb_almonLag(x,y);
                betaHyp = [ones(1,nSteps);-ones(1,nSteps);zeros(1,nSteps)]; % Initial values
                betaHyp = repmat(betaHyp,nExo);
                ub      = inf(size(betaHyp)); % Upper bound
                lb      = -inf(size(betaHyp)); % Lower bound

            case 'beta'

                func    = @(x,y)nb_betaLag(x,y);
                betaHyp = [ones(1,nSteps);ones(1,nSteps);ones(1,nSteps)*4]; % Initial values
                betaHyp = repmat(betaHyp,nExo);
                ub      = inf(3*nExo,nSteps); % Upper bound
                lb      = [-inf(1,nSteps);ones(2,nSteps)*eps]; % Lower bound
                lb      = repmat(lb,nExo);

            otherwise
                error([mfilename ':: Unsupported MIDAS type ' type])   
        end
    
        numCoeff    = size(betaHyp,1);
        nLags       = options.nLags;
        indInBeta   = size(beta,1)-2:size(beta,1);
        indScale    = constant+AR+1;
        indTheta    = constant+AR+2:constant+AR+3;
        indHyper    = [1:constant+AR,constant + AR + nExo*nLags + 1:constant + AR + nExo*(nLags + 3)];
        indNotHyper = constant + AR + 1:constant + AR + nExo*nLags;
        for ii = 1:nSteps

            ysim    = nb_midasBootstrap(beta(indInBeta,ii),residual(1:end-ii+1,ii),x(1:end-ii+1,:),constant,func,nExo,AR,draws);
            dd      = 1;
            tries   = 1;
            betaSim = nan(size(betaHyp,1),1,draws);
            while dd <= draws

                [err,betaSimT,~,~,~,resid] = nb_nls(betaHyp(:,ii),ub(:,ii),lb(:,ii),options.optimset,options.optimizer,...
                                               options.covrepair,@nb_midasResiduals,ysim(:,tries),x(1:end-ii+1,:),constant,func,nExo,AR);
                tries = tries + 1;
                if tries > size(ysim,3)
                    tries = 1;
                    ysim    = nb_midasBootstrap(betaHyp(:,ii),residual(1:end-ii+1,ii),x(1:end-ii+1,:),constant,func,nExo,AR,draws/10);
                end
                if ~isempty(err)
                    continue
                end
                betaSim(:,:,start+dd)      = betaSimT;
                sigmaDraws(ii,ii,start+dd) = resid'*resid/(size(resid,1) + 1 - numCoeff);
                dd                         = dd + 1;

            end
            betaDraws(indHyper,ii,:)    = betaSim;
            betaDraws(indNotHyper,ii,:) = bsxfun(@times,betaSim(indScale,:,:),func(permute(betaSim(indTheta,:,:),[2,1,3]),nLags));

        end
    
    end
    
end

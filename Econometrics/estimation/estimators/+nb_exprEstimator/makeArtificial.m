function [YDRAW,X] = makeArtificial(model,options,results,method,draws,iter)
% Syntax:
%
% [YDRAW,X] = nb_exprEstimator.makeArtificial(model,options,results,...
%                                       method,draws,iter)
%
% Description:
%
% Make artificial data from model by simulation.
%
% Caution: The options struct is assumed to already be index by iter!
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    resid    = results.residual(:,:,iter); 
    indN     = ~isnan(resid(:,1));
    resid    = resid(indN,:); % Remove nan given that we could be dealing with recursive estimation

    % Then we bootstrap the residuals
    E = nb_bootstrap(resid,draws,method);
    E = permute(E,[3,1,2]);
    
    % Produce forecast
    beta = results.beta;
    if size(beta{1},3) > 1
        for ii = 1:size(beta,2)
            beta{ii} = beta{ii}(:,:,iter);
        end
    end
    
    % Get the estimation data
    nDep     = size(beta,2);
    Z        = options.data;
    T        = size(Z,1);
    y        = nan(T,nDep);
    nExo     = options.nExo;
    X        = nan(T,sum(nExo));
    timespan = options.nLags+1:T;
    kk       = 0;
    for ii = 1:nDep
        y(timespan,ii) = options.depFuncs{ii}(Z,timespan);
        exoFuncsOne    = options.exoFuncs{ii};
        for jj = 1:nExo(ii)
            X(timespan,kk + jj) = exoFuncsOne{jj}(Z,timespan);
        end
        kk = kk + nExo(ii);
    end
    
    % Create artificial data
    nobs     = size(resid,1);
    start    = options.estim_start_ind;
    finish   = start + nobs - 1;
    YDRAW    = y(:,:,ones(1,draws));
    timespan = start:finish;
    kk       = 1;
    for jj = 1:nDep
        indX                 = kk:kk + nExo(jj) - 1;
        YDRAW(timespan,jj,:) = bsxfun(@plus,X(timespan,indX)*beta{jj},E(:,jj,:));
        kk                   = kk + nExo(ii);
    end
    YDRAW = YDRAW(timespan,:,:);
    X     = X(timespan,:);
    
end

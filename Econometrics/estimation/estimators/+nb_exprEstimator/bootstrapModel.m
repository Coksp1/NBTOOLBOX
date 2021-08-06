function [betaDraws,sigmaDraws,options] = bootstrapModel(solution,options,results,method,draws,iter)
% Syntax:
%
% [betaDraws,sigmaDraws,options] = nb_exprEstimator.bootstrapModel(model,...
%                                   options,results,method,draws,iter)
%
% Description:
%
% Bootstrap model.
%
% Caution: The options struct is assumed to already be index by iter!
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 6
        iter = 'end';
    end
    if strcmpi(iter,'end')
        betaT = results.beta{1};
        iter  = size(betaT,3);
    end
    numCoeff    = options.nExo;
    maxNumCoeff = max(numCoeff) + options.constant + options.time_trend;

    % Make artificial data
    %-----------------------
    [y,X] = nb_exprEstimator.makeArtificial(solution,options,results,...
                method,draws,iter);
    
    % Do the bootstrapping
    %----------------------
    nEq        = size(results.sigma,1);
    betaDraws  = cell(1,draws);
    sigmaDraws = nan(nEq,nEq,draws);
    beta       = cell(1,nEq);
    T          = size(y,1);
    res        = nan(T,nEq);
    for ii = 1:draws
        % Estimate on artificial data.
        kk = 1;
        for jj = 1:nEq
            indX                       = kk:kk + numCoeff(jj) - 1;
            [beta{jj},~,~,~,res(:,jj)] = nb_ols(y(:,jj,ii),X(:,indX),options.constant,options.time_trend);
            kk                         = kk + numCoeff(jj);
        end
        sigmaDraws(:,:,ii) = res'*res/(size(res,1) - maxNumCoeff);
        betaDraws{ii}      = beta;
    end
    
end

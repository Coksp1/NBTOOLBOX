function [betaDraws,sigmaDraws,estOpt] = bootstrapModel(model,options,results,method,draws,iter)
% Syntax:
%
% [betaDraws,sigmaDraws,estOpt] = nb_missingEstimator.bootstrapModel(...
%                                 model,options,results,method,draws,iter)
%
% Description:
%
% Bootstrap model.
%
% Caution: The options struct is assumed to already be index by iter!
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 6
        iter = 'end';
    end

    if strcmpi(iter,'end')
        A = model.A;
        if isempty(A)
            A = model.B;
        end
        if iscell(A)
            A = A{1};
        end
        iter = size(A,3);
    end

    % Make artificial data
    %-----------------------
    makeFunc                           = str2func(['nb_' options.estim_method 'Estimator.makeArtificial']);
    [YDRAW,start,finish,indY,startEst] = makeFunc(model,options,results,method,draws,iter);
    
    % Setup for bootstrapping
    %------------------------
    tempOpt                 = options;
    tempOpt.modelSelection  = '';
    tempOpt.recursive_estim = 0;
    tempOpt.estim_start_ind = startEst;
    tempOpt.maxLagLength    = tempOpt.nLags + 1;
    tempOpt.nLags           = 0; % The lags are already included in the right hand side variables of the model
    tempOpt.doTest          = 0;
    
    % Do the bootstrapping
    %----------------------
    betaDraws  = nan(size(results.beta,1),size(results.beta,2),draws);
    sigmaDraws = nan(size(results.sigma,1),size(results.sigma,2),draws);
    for ii = 1:draws
        
        % Assign the artificial data
        tempOpt.data(1:start-1,indY)    = nan;
        tempOpt.data(start:finish,indY) = YDRAW(:,:,ii);

        % We remove the observation which where originally missing
        [~,indV]                     = ismember(tempOpt.missingVariables,tempOpt.dataVariables);
        varData                      = tempOpt.data(:,indV);
        varData(tempOpt.missingData) = nan;
        tempOpt.data(:,indV)         = varData;
        
        % Update the missing options as well
        tempOpt.missingData(1:start-1,:) = true;
        tempOpt.missingStartInd          = start - 1;
        
        % Estimate on artificial data. 
        [res,estOpt]       = nb_missingEstimator.estimate(tempOpt,false);
        betaDraws(:,:,ii)  = res.beta;
        sigmaDraws(:,:,ii) = res.sigma;
        
    end
    
end

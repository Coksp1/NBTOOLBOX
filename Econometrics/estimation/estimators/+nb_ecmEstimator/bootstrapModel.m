function [betaDraws,sigmaDraws,estOpt] = bootstrapModel(model,options,results,method,draws,iter)
% Syntax:
%
% [betaDraws,sigmaDraws,estOpt] = nb_ecmEstimator.bootstrapModel(...
%                                  model,options,results,method,draws,iter)
%
% Description:
%
% Bootstrap model.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
    [YDRAW,start,finish,indY,startEst] = nb_ecmEstimator.makeArtificial(model,options,results,method,draws,iter);
    
    % Setup for bootstrapping
    %------------------------
    if iscell(options.nLags)
        nLags = max([options.nLags{:}]) + 1;
    else
        nLags = options.nLags + 1;
    end
    
    tempOpt                 = options;
    tempOpt.modelSelection  = '';
    tempOpt.recursive_estim = 0;
    tempOpt.estim_start_ind = startEst;
    tempOpt.maxLagLength    = nLags;
    tempOpt.nLags           = 0; % The lags are already included in the right hand side variables of the model
    tempOpt.doTest          = 0;
    tempOpt.bootstrap       = true;
    
    % Do the bootstrapping
    %----------------------
    betaDraws  = nan(size(results.beta,1),size(results.beta,2),draws);
    sigmaDraws = nan(size(results.sigma,1),size(results.sigma,2),draws);
    for ii = 1:draws
        
        % Assign the artificial data
        tempOpt.data(1:start-1,indY)    = nan;
        tempOpt.data(start:finish,indY) = YDRAW(:,:,ii);

        % Estimate on artificial data. 
        [res,estOpt]       = nb_ecmEstimator.estimate(tempOpt);
        betaDraws(:,:,ii)  = res.beta;
        sigmaDraws(:,:,ii) = res.sigma;
        
    end
    
end

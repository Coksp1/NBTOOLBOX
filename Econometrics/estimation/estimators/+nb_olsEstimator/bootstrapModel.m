function [betaDraws,sigmaDraws,estOpt] = bootstrapModel(model,options,results,method,draws,iter)
% Syntax:
%
% [betaDraws,sigmaDraws,estOpt] = nb_olsEstimator.bootstrapModel(model,...
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
    [YDRAW,start,finish,indY,startEst] = nb_olsEstimator.makeArtificial(model,options,results,method,draws,iter);
    
    % Setup for bootstrapping
    %------------------------
    tempOpt                 = options;
    tempOpt.modelSelection  = '';
    tempOpt.recursive_estim = 0;
    tempOpt.estim_start_ind = startEst;
    tempOpt.maxLagLength    = tempOpt.nLags + 1;
    tempOpt.doTest          = 0;
    tempOpt.addLags         = false;
    tempOpt.estim_end_ind   = [];
    
    % Do the bootstrapping
    %----------------------
    betaDraws  = nan(size(results.beta,1),size(results.beta,2),draws);
    sigmaDraws = nan(size(results.sigma,1),size(results.sigma,2),draws);
    for ii = 1:draws
        
        % Assign the artificial data
        if start > 1
            tempOpt.data(1:start-1,indY) = nan;
        end
        tempOpt.data(start:finish,indY) = YDRAW(:,:,ii);

        % Estimate on artificial data. 
        [res,estOpt]       = nb_olsEstimator.estimate(tempOpt);
        betaDraws(:,:,ii)  = res.beta;
        sigmaDraws(:,:,ii) = res.sigma;
        
    end
    
end

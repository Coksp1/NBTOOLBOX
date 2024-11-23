function [betaDraws,sigmaDraws,yD,pD] = myDrawParamFunc(results,options,draws,iter)
% Syntax:
%
% [betaDraws,sigmaDraws,yD,pD] = myDrawParamFunc(results,options,...
%       draws,iter)
%
% Description:
%
% This is an example file on how to program your own model, and make it
% work with the rest of NB toolbox.
% 
% See also:
% nb_manualEstimator.drawParameters
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Not in use, as this model does not handle missing observations!
    yD = nan(0,0,draws);
    pD = nan(0,0,0,draws);
    
    % Solve model
    if isempty(options.solveFunc)
        error(['You need to provide the solveFunc options to draw from ',...
            'the distribution of the parameters for this manually programmed model.'])
    end
    solveFunc      = str2func(options.solveFunc);
    solution       = solveFunc(results,options);
    solution.class = 'nb_manualModel';
    
    % Make artificial data (This method work in this particular case!)
    if strcmp(iter,'end')
        iter = size(solution.A,3);
    end
    YDRAW = nb_makeArtificial(solution,options,results,'bootstrap',draws,iter);
    
    % Other outputs
    if options.recursive_estim 
        finish = options.recursive_estim_start_ind + iter - 1;
        if ~isempty(options.rollingWindow)
            start = finish - size(YDRAW,1) + 1;
        else
            start = options.estim_start_ind;
        end
    else
        finish = options.estim_end_ind;
        start  = options.estim_start_ind;
    end
    if ~isempty(options.rollingWindow)
        startEst = start;
    else
        startEst = options.estim_start_ind;
    end
    
    % Correct sample + append initial value
    [~,indY] = ismember(options.dependent,options.dataVariables);
    YInit    = options.data(start-options.AR:start-1,indY);
    YInit    = YInit(:,:,ones(1,draws));
    YDRAW    = [YInit;YDRAW(:,1,:)];
    start    = start - options.AR;

    % Setup for bootstrapping
    tempOpt                 = options;
    tempOpt.recursive_estim = 0;
    tempOpt.estim_start_ind = startEst;
    tempOpt.estim_end_ind   = [];
    
    % Do the bootstrapping
    betaDraws  = nan(size(results.beta,1),size(results.beta,2),draws);
    sigmaDraws = nan(size(results.sigma,1),size(results.sigma,2),draws);
    for ii = 1:draws
        
        % Assign the artificial data
        if start > 1
            tempOpt.data(1:start-1,indY) = nan;
        end
        tempOpt.data(start:finish,indY) = YDRAW(:,:,ii);

        % Estimate on artificial data. 
        res                = nb_manualEstimator.estimate(tempOpt);
        betaDraws(:,:,ii)  = res.beta;
        sigmaDraws(:,:,ii) = res.sigma;
        
    end

end


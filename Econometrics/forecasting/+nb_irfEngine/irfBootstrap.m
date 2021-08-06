function [irfDataD,paused] = irfBootstrap(model,options,results,inputs)
% Syntax:
%
% [irfDataD,paused] = nb_irfEngine.irfBootstrap(model,options,results,...
%                       inputs)
%
% Description:
%
% Produce IRFs with error bands using bootstrap methods
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Check if we are going to parallelize
    if isfield(inputs,'parallelL')
        if inputs.parallelL
            [irfDataD,paused] = nb_irfEngine.doParallel('irfBootstrap',model,options,results,inputs);
            return
        end
    end

    % Get some inputs
    method         = inputs.method;
    periods        = inputs.periods;
    shocks         = inputs.shocks;
    vars           = inputs.variables;
    replic         = inputs.replic;
    variablesLevel = inputs.variablesLevel;
    nVars          = length(vars) + length(variablesLevel);
    nShocks        = length(shocks);
    
    % Check if we should start from paused output
    if inputs.continue
    	irfDataD = inputs.irfData;
        tested   = irfDataD(1,1,1,:);
        tested   = permute(tested,[4,1,2,3]);
        kk       = sum(~isnan(tested));
    else
        irfDataD = nan(periods+1,nVars,nShocks,replic);
        kk       = 0;
    end
    
    % Create wait bar window
    if isfield(inputs,'waitbar')
        waitbar = inputs.waitbar;
    else
        waitbar = true;
    end
    
    index   = '1';
    display = false;
    if inputs.parallel || ~waitbar % When parallel waitbar does not work!
        display = true;
        index   = int2str(inputs.index);
        h       = [];
    else
        if isfield(inputs,'index')
            h = nb_waitbar5([],['Bootstrap (IRF). Model ' int2str(inputs.index) ' of ' int2str(inputs.nObj)],true,inputs.pause);
        else
            h = nb_waitbar5([],'Bootstrap (IRF)',true,inputs.pause);
        end  
        h.maxIterations1 = replic;
        h.text1          = 'Drawing parameters (this could take some time)...';  
        h.status1        = kk; 
    end
    
    
    % Only allow one identification per draws?
    if isfield(model,'identification')
        model.identification.draws         = 1;
        model.identification.stabilityTest = inputs.stabilityTest;
    end

    % Bootstrap coefficients
    if isfield(options,'missingData')
        bootstrapFunc = str2func('nb_missingEstimator.bootstrapModel');
    else
        bootstrapFunc = str2func([options.estimator '.bootstrapModel']);
    end
    [betaD,sigmaD,estOpt] = bootstrapFunc(model,options,results,method,replic-kk);
    
    % Get the draws
    %.....................
    ii       = 0;
    jj       = kk;
    func     = str2func([model.class, '.solveNormal']);
    paused   = false;
    res      = results;
    if isfield(results,'densities')
        dens = results.densities;
    else
        dens = [];
    end
    
    note = nb_when2Notify(replic);
    while kk < replic

        ii = ii + 1;
        jj = jj + 1;
        
        % Assign the results struct the posterior draw (Only using the last
        % periods estimation if recursive estimation is done)
        try
            res.beta  = betaD(:,:,ii);
            res.sigma = sigmaD(:,:,ii);
        catch %#ok<CTCH>            
            % Out of draws, so we need more!
            [betaD,sigmaD,~] = bootstrapFunc(model,options,results,method,ceil(replic*inputs.newReplic));
            ii               = 0;
            continue
        end
        
        % Solve the model given the parameter draw, identification can fail
        % so then we just continue
        try
            if isfield(model,'identification')
                modelDraw = func(res,estOpt,model.identification); % stabilityTest is don inside this function!
            else
                modelDraw = func(res,estOpt);
                if inputs.stabilityTest
                    [~,~,modulus] = nb_calcRoots(modelDraw.A);
                    if any(modulus > 1)
                        continue
                    end
                end  
            end
        catch %#ok<CTCH>
            continue
        end
        
        kk = kk + 1;
        
        % Report current estimate in the waitbar's message field
        paused = nb_irfEngine.report(inputs,h,index,kk,jj,display,note);
        if paused
            return
        end
        
        % Calculate impulse responses given the draw
        irfDataD(:,:,:,kk) = nb_irfEngine.irfPoint(modelDraw,estOpt,inputs,results);
        
    end
    
    % Delete the waitbar.
    if ~display
        delete(h)
    end
      
end

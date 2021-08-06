function [irfDataD,paused] = irfPosterior(model,options,results,inputs)
% Syntax:
%
% [irfDataD,paused] = nb_irfEngine.irfPosterior(model,options,inputs)
%
% Description:
%
% Produce IRFs with error bands using posterior draws.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Check if we are going to parallelize
    if isfield(inputs,'parallelL')
        if inputs.parallelL
            [irfDataD,paused] = nb_irfEngine.doParallel('irfPosterior',model,options,results,inputs);
            return
        end
    end

    % Get some inputs
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
        h       = false;
    else
        if isfield(inputs,'index')
            h = nb_waitbar5([],['Posterior draws (IRF). Model ' int2str(inputs.index) ' of ' int2str(inputs.nObj)],true,inputs.pause);
        else
            h = nb_waitbar5([],'Posterior draws (IRF)',true,inputs.pause);
        end
        h.lock           = 2;
        h.maxIterations1 = replic;
        h.text1          = 'Starting...'; 
        h.status1        = kk; 
    end
    
    % Only allow one identification per posterior draws?
    if isfield(model,'identification')
        model.identification.draws         = 1;
        model.identification.stabilityTest = inputs.stabilityTest;
    end
       
    if ~isfield(options,'pathToSave')
        error([mfilename ':: No estimation is done, so can''t draw from the posterior.'])
    end
    try
        posterior = nb_loadDraws(options.pathToSave);
    catch Err
        nb_error('It seems to me that the estimation results has been saved in a folder you no longer have access to.',Err)
    end
    posterior = posterior(end);
    if display && ~inputs.parallel
        % When in parallel we need to secure that different parameter sets
        % are used. This was the easiest way to secure this...
        [betaD,sigmaD] = nb_drawFromPosterior(posterior,replic,false);
    else
        betaD  = posterior.betaD;
        sigmaD = posterior.sigmaD;
    end
    
    if isfield(results,'estimationIndex')
        estInd  = results.estimationIndex;
        estInd2 = 1; 
    else
        estInd  = true(size(betaD,1),1);
        estInd2 = true(size(betaD,2),1);
        results = struct('beta',[],'sigma',[]);
    end
    
    ii     = 0;
    jj     = kk;
    paused = false;
    note   = nb_when2Notify(replic);
    func   = str2func([model.class, '.solveNormal']);
    while kk < replic

        ii = ii + 1;
        
        % Assign the results struct the posterior draw (Only using the last
        % periods estimation if recursive estimation is done)
        try
            results.beta(estInd,estInd2) = betaD(:,:,ii);
            results.sigma                = sigmaD(:,:,ii);
        catch %#ok<CTCH>            
            % Out of posterior draws, so we need more!
            [betaD,sigmaD] = nb_drawFromPosterior(posterior,ceil(replic*inputs.newReplic),h);
            ii             = 0;
            continue
        end
        
        jj = jj + 1;
        
        % Solve the model given the posterior draw, identification can fail
        % so then we just continue
        try
            if isfield(model,'identification')
                modelDraw = func(results,options,model.identification);
            else
                modelDraw = func(results,options);
                if inputs.stabilityTest
                    [~,~,modulus] = nb_calcRoots(modelDraw.A);
                    if any(modulus > 1)
                        error('Just throw an error')
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
        irfDataD(:,:,:,kk) = nb_irfEngine.irfPoint(modelDraw,options,inputs,results);

    end
    
    % Delete the waitbar.
    if ~display
        delete(h)
    end 
    
end

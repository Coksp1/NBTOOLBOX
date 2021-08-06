function [irfDataD,paused] = irfFactorModelBootstrap(model,options,results,inputs)
% Syntax:
%
% [irfDataD,paused] = nb_irfEngine.irfFactorModelBootstrap(model,...
%                                            options,results,inputs)
%
% Description:
%
% Produce IRFs with error bands of factor models using bootstrap methods.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Check if we are going to parallelize
    if isfield(inputs,'parallelL')
        if inputs.parallelL
            [irfDataD,paused] = nb_irfEngine.doParallel('irfFactorModelBootstrap',model,options,results,inputs);
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
        h.(['maxIterations' index]) = replic;
        h.(['text' index]) = 'Starting...'; 
        h.(['status' index]) = kk; 
    end

    % Only allow one identification per draws?
    if isfield(model,'identification')
        model.identification.draws         = 1;
        model.identification.stabilityTest = inputs.stabilityTest;
    end

    % Make the parameter draws
    %..........................
    if isfield(options,'factorsLags')
        maxLag = max(options.factorsLags,max(options.nLags));
    else
        maxLag = options.nLags;
    end
    options.stdType   = method;
    options.stdReplic = replic-kk;
    [betaDraws,lambdaDraws,sigmaDraws,~,factorDraws] = nb_fmEstimator.bootstrapModel(options,results);
    
    % Get the initial values of the drawn factors
    factorDraws = factorDraws(end-maxLag+1:end,:,:);
    [s1,s2,s3]  = size(factorDraws);
    factorDraws = reshape(factorDraws,[1,s1*s2,s3]);
    factorDraws = permute(factorDraws,[2,1,3]);
    factors     = [options.factors,nb_cellstrlag(options.factors,maxLag-1,'varFast')];
    [~,indF]    = ismember(factors,model.endo);
    medianFactor = median(factorDraws,3); 
    
    if iscell(betaDraws)
        nEqs    = size(betaDraws,2);
        betaD   = cell(1,nEqs);
        sigmaD  = cell(1,nEqs);
    end
    
    % Get the draws
    %.....................  
    ii       = 0;
    jj       = kk;
    func     = str2func([model.class, '.solveNormal']);
    y0       = zeros(length(model.endo),1);
    paused   = false;
    note     = nb_when2Notify(replic);
    while kk < replic

        ii = ii + 1;
        jj = jj + 1;
        
        % Assign the bootstrapped draws
        try
            if iscell(betaDraws)
                
                for mm = 1:nEqs
                    betaD{mm}   = betaDraws{mm}(:,:,ii);
                    sigmaD{mm}  = sigmaDraws{mm}(:,:,ii);
                end
                res.beta   = betaD;
                res.lambda = lambdaDraws(:,:,ii);
                res.sigma  = sigmaD;
                
            else
                res.beta   = betaDraws(:,:,ii);
                res.lambda = lambdaDraws(:,:,ii);
                res.sigma  = sigmaDraws(:,:,ii);
            end
            
        catch %#ok<CTCH>
            
            % We need to bootstrap more artificial data
            options.stdReplic = replic*inputs.newReplic;
            [betaDraws,lambdaDraws,sigmaDraws,~,factorDraws] = nb_fmEstimator.bootstrapModel(options,results);
            ii = 1;
            
            % Get the initial values of the drawn factors
            factorDraws = factorDraws(end-maxLag+1:end,:,:);
            [s1,s2,s3]  = size(factorDraws);
            factorDraws = reshape(factorDraws,[1,s1*s2,s3]);
            factorDraws = permute(factorDraws,[2,1,3]);
            
            if iscell(betaDraws)
                
                for mm = 1:nEqs
                    betaD{mm}   = betaDraws{mm}(:,:,ii);
                    sigmaD{mm}  = sigmaDraws{mm}(:,:,ii);
                end
                res.beta   = betaD;
                res.lambda = lambdaDraws(:,:,ii);
                res.sigma  = sigmaD;
                
            else
                res.beta   = betaDraws(:,:,ii);
                res.lambda = lambdaDraws(:,:,ii);
                res.sigma  = sigmaDraws(:,:,ii);
            end
            
        end
       
        % Solve the model given the parameter draw, identification can fail
        % so then we just continue
        try
            if isfield(model,'identification')
                modelDraw = func(res,options,model.identification);
            else
                modelDraw = func(res,options);
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
        
        % As we are dealing with uncertainty in the factors we need
        % to change the starting values accordingly
        y0(indF)  = factorDraws(:,:,ii) - medianFactor;
        inputs.y0 = y0; 
        
        % Calculate impulse responses given the draw
        irfDataD(:,:,:,kk) = nb_irfEngine.irfPoint(modelDraw,options,inputs,results);
           
    end
    
    % Delete the waitbar.
    if ~display
        delete(h)
    end
      
end

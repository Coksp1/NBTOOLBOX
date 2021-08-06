function decomp = nb_varDecomp(model,options,results,inputs)
% Syntax:
%
% decomp = nb_varDecomp(model,options,results,inputs)
%
% Description:
%
% Variance decomposition of a model on the companion form.
% 
% Input:
% 
% - model    : A struct storing the companion form of the model:
%
%              y_t = A*y_t_1 + B*x_t + C*e_t
%
%              Fields:
%
%              > A    : See the equation above. A nendo x nendo 
%                       double.
%
%              > B    : See the equation above. A nendo x nexo 
%                       double.
%
%              > C    : See the equation above. A nendo x nresidual 
%                       double.
%
%              > endo : A cellstr with the decleared endogenous 
%                       variables.
%
%              > exo  : A cellstr with the decleared exogenous 
%                       variables.
%
%              > res  : A cellstr with the decleared 
%                       residuals/shocks.
%
%              > vcv  : Variance/covariance matrix of the 
%                       residuals/shocks.
%
% - options   : Estimation options. Output from the estimator functions.
%               E.g. nb_olsEstimator.estimate.
%
% - results   : Estimation results. Output from the estimator functions.
%               E.g. nb_olsEstimator.estimate. Need the residual to
%               bootstrap.
%
% - inputs    : See nb_model_genric.variance_decomposition.
% 
% Output:
% 
% - decomp : If perc is empty; A nHor x nShocks + 1 x nVar
%            otherwise; A nHor x nShocks + 1 x nVar x nPerc + 1, 
%            where the median will be at decomp(:,:,:,end).
%
%            Caution: The residual variance will be at decomp(:,end,:,:)
%
%            Caution: See the input output!
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    perc   = inputs.perc;
    method = inputs.method;
    
    % Check inputs
    %--------------------------------------------------------------
    if strcmpi(options.estimType,'bayesian')
        if isempty(method)
            method = 'posterior';
        elseif ~strcmpi(method,'posterior')
            error([mfilename ':: Density forecast method ''posterior'' is the only supported method for bayesian models.']) 
        end
    else
        if isempty(method)
            method = 'bootstrap';
        elseif strcmpi(method,'posterior')
            error([mfilename ':: Density forecast method ''posterior'' is only supported for bayesian methods.']) 
        end
    end  
    
    % Produce FEVD
    %----------------------------------------------------------------------
    if and(isempty(perc) || inputs.replic == 1, isempty(inputs.foundReplic)) % Not produce error bands
        decomp = decompPoint(model,options,inputs);  
    else % Produce error bands
        
        if ~isempty(inputs.foundReplic)
            
            modelDraws = inputs.foundReplic;
            replic     = numel(modelDraws);
            nVars      = length(inputs.variables);
            nShocks    = length(inputs.shocks);
            nHor       = size(inputs.horizon,2);
            decompD    = nan(nHor,nShocks+1,nVars,replic);
            for ii = 1:replic
                decompD(:,:,:,ii) = decompPoint(modelDraws(ii),options,inputs);
            end
            
        else
            
            % Then we make draws of the decomposition
            switch lower(method)
                case {'bootstrap','wildbootstrap','blockbootstrap','mblockbootstrap','rblockbootstrap','wildblockbootstrap','copulabootstrap'}
                    decompD = decompBootstrap(model,options,results,inputs);
                case 'identdraws'
                    decompD = decompIdentDraws(model,options,inputs);
                case 'posterior'
                    decompD = decompPosterior(model,options,inputs);
                otherwise
                    error([mfilename ':: Unsupported error band method; ' method '.'])
            end
            
        end
        
        % Get the actual lower and upper percentiles
        perc = nb_interpretPerc(perc,false);
        
        % Get the percentiles
        %.....................
        nPerc   = size(perc,2);
        nHor    = length(inputs.horizon);
        nVars   = length(inputs.variables);
        nShocks = length(inputs.shocks);
        decomp  = nan(nHor,nShocks+1,nVars,nPerc+2);
        for ii = 1:nPerc
            decomp(:,:,:,ii) = prctile(decompD,perc(ii),4);
        end
        decomp(:,:,:,end-1) = median(decompD,4);

        % Find the closest to median
        decomp(:,:,:,end) = nb_closestTo(decompD,decomp(:,:,:,end-1),4,'abs');
        
    end
    
end

%==========================================================================
% SUB
%==========================================================================
function decompD = decompBootstrap(model,options,results,inputs)

    horizon  = inputs.horizon;
    shocks   = inputs.shocks;
    vars     = inputs.variables;
    method   = inputs.method;
    replic   = inputs.replic;

    % Create waiting bar window
    if isfield(inputs,'index')
        h = nb_waitbar([],['Bootstrap (FEVD). Model ' int2str(inputs.index) ' of ' int2str(inputs.nObj)],replic,true);
    else
        h = nb_waitbar([],'Bootstrap (FEVD)',replic,true);
    end
    h.text = 'Drawing parameters (this could take some time)...';  

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
    [betaD,sigmaD,estOpt] = bootstrapFunc(model,options,results,method,replic);
    
    % Get the draws
    %.....................
    nVars   = length(vars);
    nShocks = length(shocks);
    nHor    = size(horizon,2);
    decompD = nan(nHor,nShocks+1,nVars,replic);
    
    kk   = 0;
    ii   = 0;
    jj   = 0;
    func = str2func([model.class, '.solveNormal']);
    note = nb_when2Notify(replic);
    while kk < replic

        ii = ii + 1;
        
        % Assign the results struct the posterior draw (Only using the last
        % periods estimation if recursive estimation is done)
        try
            res.beta  = betaD(:,:,ii);
            res.sigma = sigmaD(:,:,ii);
        catch %#ok<CTCH>            
            % Out of draws, so we need more!
            [betaD,sigmaD,~] = bootstrapFunc(model,options,results,method,ceil(parameterDraws*inputs.newDraws));
            ii               = 0;
            continue
        end
        
        jj = jj + 1;
        
        % Solve the model given the bootstraped draw, identification can 
        % fail so then we just continue
        try
            if isfield(model,'identification')
                modelDraw = func(res,estOpt,model.identification);
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
        if h.canceling
            error([mfilename ':: User terminated'])
        end
        
        if rem(kk,note) == 0
            h.status = kk;
            h.text   = ['Finished with ' int2str(kk) ' replications in ' int2str(jj) ' tries...'];
        end
        
        % Calculate impulse responses given the draw
        decompD(:,:,:,kk) = decompPoint(modelDraw,estOpt,inputs);

    end
    
    % Delete the waitbar.
    delete(h) 
    
end

%==========================================================================
function decompD = decompIdentDraws(model,options,inputs)

    horizon  = inputs.horizon;
    shocks   = inputs.shocks;
    vars     = inputs.variables;
    perc     = inputs.perc;

    % Check that we are dealing with a VAR identified with sign restriction
    % and that draws of C has been done
    C      = model.C;
    replic = size(C,4);
    if replic == 1
        error([mfilename ':: You need to make draws of the matrix of the map from structural shocks '...
            'to dependent variables. See the method set_identification of the nb_var class (or subclasses '...
            'of this class).'])
    elseif replic < size(perc)
        error([mfilename ':: The number of draws of the matrix of the map from structural shocks '...
            'to dependent variables must at least be larger then the percentiles to calculate.'])
    end
    
    % Create waiting bar window
    if isfield(inputs,'index')
        h = nb_waitbar([],['Uses draws from identified matrices (FEVD). Model ' int2str(inputs.index) ' of ' int2str(inputs.nObj)],replic,true);
    else
        h = nb_waitbar([],'Uses draws from identified matrices (FEVD)',replic,true);
    end
    h.text = 'Starting...'; 
        
    modelDraw = model;
    nVars     = length(vars);
    nShocks   = length(shocks);
    nHor      = size(horizon,2);
    decompD   = nan(nHor,nShocks+1,nVars,replic);
    note      = nb_when2Notify(replic);
    for kk = 1:replic

        % Get the draw of the matrix of the map from structural shocks
        % to dependent variables
        modelDraw.C = C(:,:,end,kk);
        
        % Calculate impulse responses given the draw
        decompD(:,:,:,kk) = decompPoint(modelDraw,options,horizon,shocks,vars);

        % Report current estimate in the waitbar's message field
        if h.canceling
            error([mfilename ':: User terminated'])
        end
        
        if rem(kk,note) == 0
            h.status = kk;
            h.text   = ['Finished with ' int2str(kk) ' replications...'];
        end
        
    end
    
    % Delete the waitbar.
    delete(h) 
    
end

%==========================================================================
function decompD = decompPosterior(model,options,inputs)

    horizon  = inputs.horizon;
    shocks   = inputs.shocks;
    vars     = inputs.variables;
    replic   = inputs.replic;

    % Create waiting bar window
    if isfield(inputs,'index')
        h = nb_waitbar5([],['Posterior draws (FEVD). Model ' int2str(inputs.index) ' of ' int2str(inputs.nObj)],true,false);
    else
        h = nb_waitbar5([],'Posterior draws (FEVD)',true,false);
    end
    h.text1          = 'Load posterior draws...'; 
    h.maxIterations1 = replic;
    h.lock           = 2;
    
    % Only allow one identification per draws?
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
    betaD     = posterior.betaD;
    sigmaD    = posterior.sigmaD;
    nVars     = length(vars);
    nShocks   = length(shocks);
    nHor      = size(horizon,2);
    decompD   = nan(nHor,nShocks+1,nVars,replic);
    kk        = 0;
    ii        = 0;
    jj        = 0;
    results   = struct('beta',[],'sigma',[]);
    func      = str2func([model.class, '.solveNormal']);
    note      = nb_when2Notify(replic);
    while kk < replic

        ii = ii + 1;

        % Assign the results struct the posterior draw (Only using the last
        % periods estimation if recursive estimation is done)
        try
            results.beta  = betaD(:,:,ii);
            results.sigma = sigmaD(:,:,ii);
        catch %#ok<CTCH>
            % Out of posterior draws, so we need more!
            [betaD,sigmaD] = nb_drawFromPosterior(posterior,replic/10,h);
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
                        continue
                    end
                end 
            end
        catch %#ok<CTCH>
            continue
        end
        
        kk = kk + 1;
        
        % Report current estimate in the waitbar's message field
        if h.canceling
            error([mfilename ':: User terminated'])
        end        
        if rem(kk,note) == 0
            h.status1 = kk;
            h.text1   = ['Finished with ' int2str(kk) ' replications in ' int2str(jj) ' tries...'];
        end
        
        % Calculate impulse responses given the draw
        decompD(:,:,:,kk) = decompPoint(modelDraw,options,inputs);

    end
    
    % Delete the waitbar.
    delete(h) 
      
end

%==========================================================================
function decomp = decompPoint(model,options,inputs) 
    
    horizon = inputs.horizon;
    shocks  = inputs.shocks;
    vars    = inputs.variables;

    try
        A     = model.A(:,:,end);
        C     = model.C(:,:,end);
        res   = model.res;
    catch %#ok<CTCH>
        error([mfilename ':: The model is not solved or the input model does not include the needed fields.'])
    end
    
    % If we are dealing with a MS model we need to integrate over different
    % regimes
    if isfield(model,'Q')
        if isempty(inputs.regime)
            [A,C] = ms.integrateOverRegime(model.Q,A,C);
        else
            A = A{inputs.regime};
            C = C{inputs.regime};
        end
    elseif iscell(A)
        if isempty(inputs.regime)
            inputs.regime = 1;
        end
        A = A{inputs.regime};
        C = C{inputs.regime};
    end
        
    indInf   = horizon == inf;
    horizonT = horizon(~indInf);
    indInf   = any(indInf);
    nSteps   = max(horizonT);
    nRes     = length(res);
    if strcmpi(model.class,'nb_dsge')
        nEq      = size(C,1);
        sigmasq  = C;
    else
        nEq      = size(C,2);
        sigmasq  = C(1:nEq,1:nEq);
    end
    MSE   = zeros(nEq,nEq,nSteps+indInf);
    MSE_j = zeros(nEq,nEq,nSteps+indInf);
    FEVD  = zeros(nSteps+indInf,nEq,nEq);
    
    % Construct the multipliers
    RHO = A(:,:,ones(1,nSteps-1));
    for kk = 2:nSteps-1
        RHO(:,:,kk) = RHO(:,:,kk-1)*A;
    end
    RHO = RHO(1:nEq,1:nEq,:);
    
    % Calculate Total Mean Squared Error
    sigma      = sigmasq*sigmasq';
    MSE(:,:,1) = sigma;
    for kk = 1:nSteps-1
       MSE(:,:,kk+1) = MSE(:,:,kk) + RHO(:,:,kk)*sigma*RHO(:,:,kk)';
    end
    
    if indInf
        Ainf              = getAinf(A,nEq);
        MSE(:,:,nSteps+1) = Ainf*sigma*Ainf';
    end
    
    % Calculate the MSE error of each residual shock
    for mm = 1:nRes 
    
        % Get the column of C corresponding to the mm_th shock
        CC = C(1:nEq,mm);
        CC = CC*CC';

        % Compute the mean square error
        MSE_j(:,:,1) = CC;
        for kk = 1:nSteps-1
            MSE_j(:,:,kk+1) = MSE_j(:,:,kk) + RHO(:,:,kk)*CC*RHO(:,:,kk)';   
        end
        
        if indInf
            MSE_j(:,:,nSteps+1) = Ainf*CC*Ainf'; 
        end

        % Compute the Forecast Error Covariance Decomposition
        FECD = MSE_j./MSE;

        % Select only the variance terms
        for nn = 1:nSteps+indInf
            for ii = 1:nEq
                FEVD(nn,mm,ii) = FECD(ii,ii,nn);
            end
        end
        
    end
    
    % Get dependent variables
    if isfield(options,'dependent') && ~strcmpi(options.class,'nb_mfvar')
        dep = options.dependent;
        if isfield(options,'block_exogenous')
            dep = [dep, options.block_exogenous];
        end
    else
        dep = model.endo; % DSGE models and MF-VAR
    end
    
    % Reorder stuff
    nShocks   = length(shocks);
    nVars     = length(vars);
    nHor      = size(horizon,2);
    [fS,indS] = ismember(res,shocks);
    indS      = indS(fS);
    [fV,indV] = ismember(dep,vars);
    indV      = indV(fV);
    horTest   = 1:nSteps;
    if indInf
       horTest = [horTest,inf]; 
    end
    [~,indH]            = ismember(horizon,horTest);
    decomp              = nan(nHor,nShocks+1,nVars);
    decomp(:,indS,indV) = FEVD(indH,fS,fV);
    
    % Make a rest variable
    decomp(:,end,:) = 1 - sum(decomp(:,1:end-1,:),2);
    
end

%==========================================================================
function Ainf = getAinf(A,k)

    p      = size(A,1)/k;
    A_temp = A(1:k,:);
    B      = zeros(k,k);
    for ii = 1:p
        ind = (1:k)+(ii-1)*k;
        B   = B + A_temp(:,ind);
    end
    Ainf = (eye(k) - B)\eye(k);
    
end

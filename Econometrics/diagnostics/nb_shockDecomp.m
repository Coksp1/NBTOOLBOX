function decomp = nb_shockDecomp(model,options,results,startInd,endInd,inputs)
% Syntax:
%
% decomp = nb_shockDecomp(model,options,results,startInd,endInd,inputs)
%
% Description:
%
% Shock decomposition of a model on the companion form as below.
% 
% Caution : For models with unobservables the filter method must be run
%           first. 
%
% Caution : This method does not allow parameter uncertainty for filtered 
%           models. 
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
%               E.g. nb_olsEstimator.estimate.
% 
% - startInd  : Start index of the shock decomposition.
%
% - endInd    : End index of the shock decomposition.
%
% - inputs    : See nb_model_generic.shock_decomposition.
%
% Output:
% 
% - decomp    : If perc is empty; A nObs x [nShock (1:end-1) + initial
%               conditions (end-1) + steady-state (end)] x nVar, otherwise; 
%               A nObs x [nShock (1:end-1) + initial conditions (end-1) + 
%               steady-state (end)] x nVar x nPerc + 1, where the closest 
%               model to the median is located at decomp(:,:,:,end)
%
%               Caution : Initial conditions are all that is not explained
%                         by the shocks.
%
%               Caution : Please have in mind that the percentiles are
%                         the numerically calculated percentiles and will
%                         not sum up the actual series!
%
% See also:
% nb_model_generic.shock_decomposition
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 6
        inputs = struct('replic',[],'method','','perc',[]);            
        if nargin < 5
            endInd = [];
            if nargin < 4
                startInd = [];  
            end
        end
    end

    if ~isfield(model,'A')
        error([mfilename ':: The model ' inputs.index ' is not solved.'])
    end
    perc   = inputs.perc;
    method = inputs.method;
    replic = inputs.replic;
    
    if isfield(results,'smoothed')
        if replic > 1 && ~isempty(perc)
            error([mfilename ':: Cannot do shock decomposition with parameter uncertainty for filtered models.'])
        end
    end
         
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
    
    % Get data to decompose (No uncertainty in exogenous variables when 
    % bootstrapping!!!)
    %-----------------------------------------------------------------
    
    if isempty(startInd) || isnan(startInd)
        if ~isfield(options,'estim_start_ind')
            error([mfilename ':: The model must be filtered/estimated to do shock decomposition.'])
        end
        startInd = options.estim_start_ind;
    end
    if isempty(endInd) || isnan(endInd)
        endInd   = options.estim_end_ind;
    end
    
    T = endInd - startInd + 1;
    if isfield(results,'smoothed')
        % Filtered variables will depend on the parameter draw, so they are
        % found later. Initialize empty matrix
        Y = [];
    else 
        if strcmpi(options.class,'nb_dsge')
            error([mfilename ':: The model must be filtered. See the nb_dsge.filter method.'])
        end
        tempData = options.data(startInd:endInd,:);
        [~,indY] = ismember(model.endo,options.dataVariables);
        Y        = tempData(:,indY); 
    end
    
    if strcmpi(options.class,'nb_dsge')
        X   = nan(T,0);
    else
        X   = nan(T,0);
        exo = model.exo;
        if isfield(options,'constant')
            constant = options.constant;
            if constant 
                X   = [X,ones(T,1)];
                exo = exo(2:end);
            end
        end

        if isfield(options,'time_trend')
            time_trend = options.time_trend;
            if time_trend
                t   = 1:T;
                X   = [X,t']; 
                exo = exo(2:end);
            end
        end
        [~,indX] = ismember(exo,options.dataVariables);
        if ~isempty(indX)
            tempData = options.data(startInd:endInd,:);
            X        = [X,tempData(:,indX)];
        end
    end
    
    % Produce shock decomp
    %----------------------------------------------------------------------
    if isempty(perc) || replic == 1 % Not produce error bands
        decomp = decompPoint(model,options,results,startInd,endInd,Y,X,inputs);  
    else % Produce error bands
        
        % Then we make draws of the decomposition
        switch lower(method)
            case {'bootstrap','wildbootstrap','blockbootstrap','mblockbootstrap','rblockbootstrap','wildblockbootstrap','copulabootstrap'}
                decompD = decompBootstrap(model,options,results,startInd,endInd,Y,X,inputs);
            case 'identdraws'
                decompD = decompIdentDraws(model,options,results,startInd,endInd,Y,X,inputs);
%             case 'mc'
%                 decompD = decompMC(model,options,results,periods,shocks,vars,perc,replic,sign);
            case 'posterior'
                decompD = decompPosterior(model,options,results,startInd,endInd,Y,X,inputs);
            otherwise
                error([mfilename ':: Unsupported error band method; ' method '.'])
        end
        
        % Get the actual lower and upper percentiles
        perc = nb_interpretPerc(perc,false);
        
        % Get the percentiles
        %.....................
        nPerc   = size(perc,2);
        nObs    = size(decompD,1);
        nVars   = length(model.endo);
        nShocks = length([model.exo,model.res]);
        decomp  = nan(nObs,nShocks+1,nVars,nPerc+1);
        for ii = 1:nPerc
            decomp(:,:,:,ii) = prctile(decompD,perc(ii),4);
        end
        decompMedian = median(decompD,4);

        % Find the closest to median
        decomp(:,:,:,end)   = nb_closestTo(decompD,decompMedian,4,'abs');
        
    end
    
end

%==========================================================================
% SUB
%==========================================================================
function decompD = decompBootstrap(model,options,results,startInd,endInd,Y,X,inputs)

    method = inputs.method;
    replic = inputs.replic;
    
    % Create waiting bar window
    if isfield(inputs,'index')
        h = nb_waitbar([],['Bootstrap (shock decomp). Model ' int2str(inputs.index) ' of ' int2str(inputs.nObj)],replic,true);
    else
        h = nb_waitbar([],'Bootstrap (shock decomp)',replic,true);
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
    nVars      = length(model.endo);
    nShocks    = length([model.exo,model.res]);
    nObs       = size(Y,1);
    decompD    = nan(nObs,nShocks+1,nVars,replic);
    
    tempOpt                 = options;
    tempOpt.nLags           = 0; % The lags are already included in the right hand side variables of the model
    tempOpt.modelSelection  = '';
    tempOpt.recursive_estim = 0;
    
    XX        = results.regressors; % Need the regressors to construct the residuals
    y         = results.predicted + results.residual;
    T         = size(y,1);
    numCoeff  = size(results.beta,1);
    
    kk   = 0;
    ii   = 0;
    jj   = 0;
    func = str2func([model.class, '.solveNormal']);
    res  = results;
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
                
        % Solve the model given the bootstraped draw, identification can fail
        % so then we just continue
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
        
        % Need the residual (of course)
        res.residual = y - XX(1:T,1:numCoeff)*res.beta;
        
        if rem(kk,note) == 0
            h.status = kk;
            h.text   = ['Finished with ' int2str(kk) ' replications in ' int2str(jj) ' tries...'];
        end
        
        % Calculate impulse responses given the draw
        decompD(:,:,:,kk) = decompPoint(modelDraw,estOpt,res,startInd,endInd,Y,X,inputs);

    end
    
    % Delete the waitbar.
    delete(h) 
    
end

%==========================================================================
function decompD = decompIdentDraws(model,options,results,startInd,endInd,Y,X,inputs)

    % Check that we are dealing with a VAR identified with sign restriction
    % and that draws of C has been done
    C      = model.C;
    replic = size(C,4);
    if replic == 1
        error([mfilename ':: You need to make draws of the matrix of the map from structural shocks '...
            'to dependent variables. See the method set_identification of the nb_var class (or subclasses '...
            'of this class).'])
    elseif replic < size(inputs.perc)
        error([mfilename ':: The number of draws of the matrix of the map from structural shocks '...
            'to dependent variables must at least be larger then the percentiles to calculate.'])
    end
    
    % Create waiting bar window
    if isfield(inputs,'index')
        h = nb_waitbar([],['Uses draws from identified matrices (shock decomp). Model ' int2str(inputs.index) ' of ' int2str(inputs.nObj)],replic,true);
    else
        h = nb_waitbar([],'Uses draws from identified matrices (shock decomp)',replic,true);
    end
    h.text = 'Starting...'; 
        
    modelDraw = model;
    nVars     = length(model.endo);
    nShocks   = length([model.exo,model.res]);
    nObs      = size(Y,1);
    decompD   = nan(nObs,nShocks+1,nVars,replic);
    note      = nb_when2Notify(replic);
    for kk = 1:replic

        % Get the draw of the matrix of the map from structural shocks
        % to dependent variables
        modelDraw.C = C(:,:,end,kk);
        
        % Calculate impulse responses given the draw
        decompD(:,:,:,kk) = decompPoint(modelDraw,options,results,startInd,endInd,Y,X,inputs);

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
function decompD = decompPosterior(model,options,results,startInd,endInd,Y,X,inputs)

    replic = inputs.replic;

    % Create waiting bar window
    if isfield(inputs,'index')
        h = nb_waitbar5([],['Posterior draws (shock decomp). Model ' int2str(inputs.index) ' of ' int2str(inputs.nObj)],true,false);
    else
        h = nb_waitbar5([],'Posterior draws (shock decomp)',true,false);
    end
    h.text1          = 'Load posterior draws...'; 
    h.maxIterations1 = replic;
    h.lock           = 2;
    
    % Only allow one identification per draws?
    if isfield(model,'identification')
        model.identification.draws         = 1;
        model.identification.stabilityTest = inputs.stabilityTest;
    end
       
    try
        posterior = nb_loadDraws(options.pathToSave);
    catch Err
        nb_error('It seems to me that the estimation results has been saved in a folder you no longer have access to.',Err)
    end 
    
    res = obj.results;
    if isfield(res,'estimationIndex')
        error([mfilename ': Cannot do shock decomposition of DSGE models with the draws from the posterior. ',...
                         'Please contact Kenneth S. Paulsen if needed.'])
    end
    
    posterior = posterior(end);
    betaD     = posterior.betaD;
    sigmaD    = posterior.sigmaD;
    nVars     = length(model.endo);
    nShocks   = length([model.exo,model.res]);
    nObs      = size(Y,1);
    decompD   = nan(nObs,nShocks+1,nVars,replic);
    kk        = 0;
    ii        = 0;
    jj        = 0;
    XX        = results.regressors; % Need the regressors to construct the residuals
    y         = results.predicted + results.residual;
    T         = size(y,1);
    numCoeff  = size(results.beta,1);
    res       = struct('beta',[],'sigma',[],'residual',[]);
    func      = str2func([model.class, '.solveNormal']);
    note      = nb_when2Notify(replic);
    while kk < replic

        ii = ii + 1;
        
        % Assign the results struct the posterior draw (Only using the last
        % periods estimation if recursive estimation is done)
        try
            res.beta  = betaD(:,:,ii);
            res.sigma = sigmaD(:,:,ii);
        catch %#ok<CTCH>
            % Out of posterior draws, so we need more!
            [betaD,sigmaD] = nb_drawFromPosterior(posterior,replic/10,h);
            ii             = 1;
        end
        
        jj = jj + 1;
        
        % Need the residual (of course)
        res.residual = y - XX(1:T,1:numCoeff)*res.beta;
        
        % Solve the model given the posterior draw, identification can fail
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
        if h.canceling
            error([mfilename ':: User terminated'])
        end 
        if rem(kk,note) == 0
            h.status1 = kk;
            h.text1   = ['Finished with ' int2str(kk) ' replications in ' int2str(jj) ' tries...'];
        end
        
        % Calculate impulse responses given the draw
        decompD(:,:,:,kk) = decompPoint(modelDraw,options,res,startInd,endInd,Y,X,inputs);

    end
    
    % Delete the waitbar.
    delete(h) 
      
end

%==========================================================================
function decomp = decompPoint(model,options,results,startInd,endInd,Y,X,inputs)

    % Data reordering
    exoNr     = length([model.exo,model.res]);
    endoNames = model.endo;
    endoNr    = length(endoNames);
    
    % Get the residuals/shocks
    if isfield(results,'smoothed') % The model has filtered unobservables
        [Y,R] = getSmoothed(model,inputs,options,results,startInd,endInd);
    else 
        sInd = startInd - options.estim_start_ind + 1;
        eInd = endInd - options.estim_start_ind + 1;
        R    = results.residual(sInd:eInd,:,end); % Uses the last residual in the case of recursive estimation 
    end
    
    if isfield(model,'identification')
        nRes = size(R,2);
        if ~nb_isempty(model.identification)
            % Get the identified shocks
            CT = model.C(1:nRes,1:nRes)';
            R  = R/CT;
        else
            model.C = [eye(nRes);zeros(endoNr-nRes,nRes)];
        end
    end
    X = [X(:,:,ones(1,size(R,3)),ones(1,size(R,4))),R];
    
    % Preallocated space (this is the matrix which the shock 
    % decomposition is solved with and stored in)
    T      = size(Y,1);
    decomp = zeros(endoNr,exoNr + 3, T,size(R,3));

    % Extract the smoothed endogenous variables from the first 
    % page of the 'smoothedDB' property. (The variables values 
    % which should be explained by the shocks.)
    decomp(:,end,:,:) = permute(Y,[2,4,1,3]); %(variables x 1 x periods x regimes)

    % Extract the residuals/innovations and exogenous variables
    E = permute(X,[2,4,1,3]); %(variables x nAnticipated x periods x regimes)
           
    % Do the shock decomposition
    inputs.startInd = startInd;
    if nb_isModelMarkovSwitching(model) % Markov switching
        error([mfilename ':: Shock decomposition is not supported for Markov Switching models.'])
    elseif iscell(model.A) % Break point model
        decomp = shockDecompositionEngineBreaks(model,results,decomp,E,inputs);
    else % One regime
        decomp = shockDecompositionEngine(1,model,results,decomp,E,inputs);
    end

    % Reorder
    decomp = permute(decomp,[3,2,1]); %(periods x shock contributions (1:end-3) + initial conditions (end-2) + steady-state (end-1) + sum (end) x endogenous variables)
    decomp = decomp(:,1:end-1,:); % Remove the sum

end

%==========================================================================
function [Y,R] = getSmoothed(model,inputs,options,results,startInd,endInd)

    realTime = false;
    if isfield(results,'realTime')
        if results.realTime
            realTime = true;
        end
    end
    
    estInd = nb_dateminus(results.filterStartDate,options.dataStartDate) + 1;
    sInd   = startInd - estInd + 1;
    eInd   = endInd - estInd + 1;
    if strcmpi(inputs.type,'updated')
        Y = results.updated.variables.data;
        R = results.updated.shocks.data;
    else
        Y = results.smoothed.variables.data;
        R = results.smoothed.shocks.data;
    end
    if realTime
        
        if isfield(model,'CE')
            nAnt = size(model.CE,3);
        else
            nAnt = 1;
        end
        if ~nb_isempty(inputs.model2)
            if isfield(inputs.model2,'CE')
                nAnt2 = size(inputs.model2.CE,3);
            else
                nAnt2 = 1;
            end
            nAnt = max(nAnt,nAnt2);
        end
        
        R = permute(R,[1,2,4,3]); % nObs x nVar x 1 x nAnticipated
        if size(R,4) ~= nAnt
            % Make sure that R has enough pages
            REXP = zeros(size(R,1),size(R,2),1,nAnt);
            REXP(:,:,:,1:size(model.CE,3)) = R;
            R    = REXP; 
        end
        if ~nb_isempty(inputs.fcstDB)
            % Load fcst as well
            if inputs.fcstDB.full
                error([mfilename ':: The ''fcstDB'' must start at estim_end_date + 1 if real time filtering is done.'])
            else
                Y     = [Y;inputs.fcstDB.endo]; 
                Rfcst = nb_addLeads(inputs.fcstDB.res,nAnt-1,4,1); % Add anticipated shocks as pages
                R     = [R;Rfcst];
            end
        end
        
    else
    
        if ~nb_isempty(inputs.fcstDB)
            % Load fcst as well
            Y = [Y(1:inputs.fcstDB.index,:);inputs.fcstDB.endo]; 
            R = [R(1:inputs.fcstDB.index,:);inputs.fcstDB.res];
            if eInd > size(Y,1)
                error([mfilename ':: The end date is after the end date of the fcstDB input.'])
            end
        end

    end
    
    Y = Y(sInd:eInd,:,:);
    R = R(sInd:eInd,:,:,:); 
    
    if strcmpi(options.class,'nb_mfvar')
        Y = Y(:,1:size(model.A,1));
    end
    
end

%==========================================================================
function q = shockDecompositionEngine(state,model,results,q,E,inputs)

    % The model matrices
    if iscell(model.A)
        A = model.A{state}(:,:,end);
        B = model.B{state}(:,:,end);
        if isfield(model,'CE')
            C = model.CE{state}; % Anticipated shocks
        else 
            C = model.C{state}(:,:,end);
        end
        ss = model.ss{state};
    else
        A = model.A(:,:,end);
        B = model.B(:,:,end);
        if isfield(model,'CE')
            C = model.CE; % Anticipated shocks
        else
            C = model.C(:,:,end);
        end
        if isfield(model,'ss')
            ss = model.ss;
        else
            ss = zeros(size(A,1),1);
        end
    end
    exoNr = length(model.res) + length(model.exo);
    
    % Remove inactive shocks
    if strcmpi(model.class,'nb_dsge')
        resFiltered = results.smoothed.shocks.variables;
        indRes      = ismember(model.res,resFiltered);
        if any(~indRes)
            C = C(:,indRes);
        end
    else
        indRes = true(1,exoNr);
    end
    
    % Merge exogenous and shocks
    B      = [B(:,:,ones(1,size(C,3))),C];
    T      = size(E,3);
    aSteps = size(B,3);
    if isfield(model,'CE') % Anticipated shocks
        if size(E,2) == 1
            %E = E(:,ones(1,size(model.CE,3)),:,:);
            E = nb_addLeads(E,size(model.CE,3)-1,2,3);
        elseif size(E,2) ~= size(model.CE,3)
            error([mfilename ':: The horizon of anticipation of shocks/residuals does not match the filtered shocks/residuals'])
        end
    end
    if size(E,3) ~= T + aSteps - 1
        ET         = E;
        E          = zeros(size(E,1),size(E,2),T + aSteps - 1);
        E(:,:,1:T) = ET;
    end
    
    % Get the index for were the shocks start to get anticipated
    if isempty(inputs.anticipationStartInd)   
        % Just to ensure that we never going to reach this period.
        tStartAntShocks = T + 1; 
    else
        tStartAntShocks = inputs.anticipationStartInd - inputs.startInd + 1;
    end
    
    % Find the observation at which second model starts
    if isempty(inputs.secondModelStartInd)

        % Just to ensure that we never going to reach the 
        % period of model 2.
        tEndFirstModel  = T;
        tEndSecondModel = []; 

    else
        tEndFirstModel  = inputs.secondModelStartInd - inputs.startInd;
        tEndSecondModel = T;
        model2          = inputs.model2;
        try
            if iscell(model2.A)
                A2 = model2.A{state}(:,:,end);
                B2 = model2.B{state}(:,:,end);
                if isfield(model2,'CE')
                    C2 = model2.CE{state}; % Anticipated shocks
                else 
                    C2 = model2.C{state}(:,:,end);
                end
            else
                A2 = model2.A(:,:,end);
                B2 = model2.B(:,:,end);
                if isfield(model2,'CE')
                    C2 = model2.CE; % Anticipated shocks
                else 
                    C2 = model2.C(:,:,end);
                end 
            end
        catch %#ok<CTCH>
            error([mfilename ':: When ''secondModelStartDate'' is given the model2 input must be a structure with the solution of the second model.'])
        end
        if strcmpi(model.class,'nb_dsge')
            indRes2 = ismember(model2.res,resFiltered);
            if any(~indRes2)
                C2 = C2(:,indRes2,:);
            end
		else
			indRes2 = true(1,exoNr);
        end
        C2 = expandSecondSolution(C,C2,model.res(indRes),model2.res(indRes2));
        B2 = [B2(:,:,ones(1,size(C2,3))),C2];
    end
    
    % Index of active shocks
    endoNr = size(A,2);
    indE   = 1:exoNr;
    indE   = indE(indRes);
    
    % Remove steady-state from the data
    q(:,end,:) = bsxfun(@minus,q(:,end,:),ss);
    
    %--------------------------------------------------------------
    % Then do the decomposition
    %--------------------------------------------------------------
    % Method which uses the fact that everything not explain by
    % the shocks is initial conditions. (Prefered)
    %--------------------------------------------------------------
    for t = 1:tEndFirstModel

        % Evolve the contribution of the shocks, which 
        % has already taken place
        if t > 1
            q(:,indE,t) = A*q(:,indE,t-1);
        end
        
        % Continue to iterate only if we are in a period with anticipations    
        if t < tStartAntShocks 
            iterate = 1;
        else
            iterate = aSteps;
        end

        % Collect all contribution from the shocks and exogenous variables
        for ii = 1:iterate
            Epage       = transpose(E(:,ii,t));
            q(:,indE,t) = q(:,indE,t) + B(:,:,ii).*Epage(ones(1,endoNr),:);
        end
        
        % Initial conditions (If some endogenous variables is
        % not explain by the shocks it will be thrown into the
        % initial condition. So if the initial condition seems
        % to have weird behavioral it is due to something
        % wrong) (If everthing is correct it will just evolve 
        % the initial conditions)
        q(:,exoNr + 1,t) = q(:,exoNr + 3,t) - sum(q(:,indE,t),2);

    end
    
    % Be sure that we are not using model 1 if the
    % first model finish before the decomposition 
    % starts
    if tEndFirstModel == T
        return
    end
    
    if tEndFirstModel < 0
        tEndFirstModel = 0;
    end
    
    aSteps = size(B2,3);
    if size(E,2) ~= aSteps
        %E = E(:,ones(1,aSteps),:);
        E = nb_addLeads(E,size(model2.CE,3)-1,2,3);
    end
    if size(E,3) ~= T + aSteps - 1
        ET         = E;
        E          = zeros(size(E,1),size(E,2),T + aSteps - 1);
        E(:,:,1:T) = ET;
    end
    
    for t = tEndFirstModel + 1:tEndSecondModel

        % Evolve the contribution of the shocks, which 
        % has already taken place
        if t > 1
            q(:,indE,t) = A2*q(:,indE,t-1);
        end
        
        % Continue to iterate only if we are in a period with anticipations    
        if t < tStartAntShocks 
            iterate = 1;
        else
            iterate = aSteps;
        end

        % Collect all contribution from the shocks and exogenous variables
        for ii = 1:iterate
            Epage       = transpose(E(:,ii,t));
            q(:,indE,t) = q(:,indE,t) + B2(:,:,ii).*Epage(ones(1,endoNr),:);
        end
        
        % Initial conditions (If some endogenous variables is
        % not explain by the shocks it will be thrown into the
        % initial condition. So if the initial condition seems
        % to have weird behavioral it is due to something
        % wrong) (If everthing is correct it will just evolve 
        % the initial conditions)
        q(:,exoNr + 1,t) = q(:,exoNr + 3,t) - sum(q(:,indE,t),2);

    end
    
end 

%==================================================================
function Ctemp = expandSecondSolution(C1,C2,res1,res2)

    Ctemp     = zeros(size(C1,1),size(C1,2),size(C2,3));
    [ind,loc] = ismember(res2,res1);
    if any(~ind)
        error([mfilename ':: The model2 solution include shocks not included in the original model; ' toString(res2(~ind))])
    end
    Ctemp(:,loc,:) = C2;
    
end
    
%==========================================================================
function q = shockDecompositionEngineBreaks(model,results,q,E,inputs)

    % The model matrices
    A  = model.A;
    B  = model.B;
    ss = model.ss;
    if isfield(model,'CE')
        C      = model.CE; % Anticipated shocks
        nPages = size(C{1},3);
    else
        C      = model.C(:,:,end);
        nPages = 1;
    end
    
    % Remove inactive shocks
    resFiltered = results.smoothed.shocks.variables;
    indRes      = ismember(model.res,resFiltered);
    if any(~indRes)
        for ii = 1:length(C)
            C{ii} = C{ii}(:,indRes);
        end
    end
    
    % Concatenate exogenous and residuals (shocks)
    for ii = 1:length(A)
        B{ii} = [B{ii}(:,:,ones(1,nPages)),C{ii}];
    end
    
    % Get the shocks
    T = size(E,3);
    if nb_isempty(inputs.model2)
        aSteps = size(B{1},3);
    else
        aSteps = size(inputs.model2.CE{end},3);
    end
    if aSteps > 1 % Anticipated shocks
        if size(E,2) == 1
            E = nb_addLeads(E,aSteps-1,2,3);
        elseif size(E,2) ~= aSteps
            error([mfilename ':: The horizon of anticipation of shocks/residuals does not match the filtered shocks/residuals'])
        end
    end
    if size(E,3) ~= T + aSteps - 1
        ET         = E;
        E          = zeros(size(E,1),size(E,2),T + aSteps - 1);
        E(:,:,1:T) = ET;
    end
    
    % Get the states
    breaks  = model.breaks;
    startF  = nb_date.date2freq(results.filterStartDate) + (inputs.startInd - 1);
    endF    = startF + (T-1);
    datesF  = startF:endF;
    states  = ones(T,1);
    for ii = 1:length(breaks)
       ind = find(strcmp(toString(breaks(ii)),datesF));
       if ~isempty(ind)
           states(ind:end) = ii + 1;
       end
    end
    
    % Get the index for were the shocks start to get anticipated
    if isempty(inputs.anticipationStartInd)   
        % Just to ensure that we never going to reach this period.
        tStartAntShocks = T + 1; 
    else
        tStartAntShocks = inputs.anticipationStartInd - inputs.startInd + 1;
    end
    
    % Some model information
    endoNr  = size(A{1},2);
    exoNr   = length(model.res);
    indE    = 1:exoNr;
    indE    = indE(indRes);
    indSS   = exoNr + 2;
    indInit = exoNr + 1;
    indAct  = exoNr + 3; 
    
    %--------------------------------------------------------------
    % Then do the decomposition
    %--------------------------------------------------------------
    % Method which uses the fact that everything not explain by
    % the shocks is initial conditions. (Prefered)
    %--------------------------------------------------------------
    q(:,indSS,1) = ss{states(1)};
    for t = 1:T

        % Evolve the contribution of the shocks, which 
        % has already taken place. Also steady-state shifts
        if t > 1
            q(:,indE,t)  = A{states(t)}*q(:,indE,t-1);
            q(:,indSS,t) = ss{states(t)} + A{states(t)}*(q(:,indSS,t-1) - ss{states(t)});
        end
        
        % Continue to iterate only if we are in a period with anticipations    
        if t < tStartAntShocks 
            iterate = 1;
            Bt      = B{states(t)};
        else
            iterate = aSteps;
            if nb_isempty(inputs.model2)
                Bt = B{states(t)};
            else
                Bt = expandSecondSolution(B{states(t)},inputs.model2.CE{states(t)},resFiltered,inputs.model2.res);
            end
        end

        % Collect all contribution from the shocks and exogenous variables
        for ii = 1:iterate
            Epage       = transpose(E(:,ii,t));
            q(:,indE,t) = q(:,indE,t) + Bt(:,:,ii).*Epage(ones(1,endoNr),:);
        end
         
    end
    
    % Initial conditions (If some endogenous variables is
    % not explain by the shocks it will be thrown into the
    % initial condition. So if the initial condition seems
    % to have weird behavioral it is due to something
    % wrong) (If everthing is correct it will just evolve 
    % the initial conditions)
    q(:,indInit,:) = q(:,indAct,:) - sum(q(:,indE,:),2) - q(:,indSS,:);
    
    % Remove the initial value of the steady-state
    q(:,indSS,:) = bsxfun(@minus,q(:,indSS,:), ss{states(1)});
    
end 

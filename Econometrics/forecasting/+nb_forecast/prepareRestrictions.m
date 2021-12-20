function restrictions = prepareRestrictions(model,options,nSteps,condDB,condDBVars,inputs,shockProps)
% Syntax:
%
% restrictions = nb_forecast.prepareRestrictions(model,options,nSteps,...
%                       condDB,condDBVars,inputs,shockProps)
%
% Description:
%
% Prepare the conditional information for forecasting routines
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    restrictions = struct();
    if inputs.condDBStart == 0
        if isempty(condDB)
            restrictions.initDB     = [];
            restrictions.initDBVars = {};
            extra                   = 0;
        else
            % Store conditional information on initial values. See
            % nb_forecast.setInitialValues2CondDB
            restrictions.initDB     = condDB(1,:);
            restrictions.initDBVars = condDBVars;
            condDB                  = condDB(2:end,:);
            extra                   = 1;
        end
    else
        extra = 0;
    end

    if ~isempty(condDB)
        if nSteps ~= size(condDB,1)
            error([mfilename ':: The condDB input (' int2str(size(condDB,1) + extra) ') must match the nSteps inputs (' int2str(nSteps) ')'])
        end
    end
    if isfield(inputs,'exoProj')
        exoProj = inputs.exoProj;
    else
        exoProj = '';
    end
         
    % Organize the conditional information, and check some stuff
    nPages           = size(condDB,3);
    softConditioning = 0;
    condDistribution = 0;
    if ~isempty(condDB)
        if isa(condDB,'nb_distribution')
            condDistribution = 1;
        else
            if nPages == 3 && inputs.nPeriods ~= 3
                softConditioning = 1;
            else
                if size(condDB,3) ~= inputs.nPeriods
                    error('nb_forecast:condDBPagePeriodMismatch',[mfilename ':: The number of forecasting periods (' int2str(inputs.nPeriods) ') does not match the number of '...
                        'pages of the condDB input (' int2str(size(condDB,3)) ')'])
                end
            end
        end
    end
    restrictions.softConditioning = softConditioning;
    restrictions.condDistribution = condDistribution;
    restrictions.type             = 1;

    % Condition on the states
    if iscell(model.A) && strcmpi(model.type,'nb')
        
        if ~isempty(inputs.states)
            error([mfilename ':: The states input is not supported when dealing with a DSGE model with unexpected break points.'])
        end
        
        % Dealing with fixed break-points
        sDate  = nb_date.date2freq(options.dataStartDate);
        sDate  = sDate + inputs.startInd;
        dates  = model.breaks;
        datesF = dates(sDate <= dates);
        if numel(datesF) == 0
            % Use last period
            states = ones(nSteps,1)*length(model.ss);
        else
            states  = ones(nSteps,1)*(length(model.ss) - length(datesF)); % Initial state
            horizon = sDate:(sDate + (nSteps-1));
            for ii = 1:length(datesF)
                ind               = find(strcmp(toString(datesF(ii)),horizon));
                states(ind:end,1) = length(model.ss) - length(datesF) + ii;
            end
        end
        restrictions.states = states;
        restrictions.state0 = find(sDate > dates,1,'last');
        if isempty(restrictions.state0)
            restrictions.state0 = 1;
        else
            restrictions.state0 = restrictions.state0 + 1;
        end
        if isfield(inputs,'condAssumption')
            restrictions.condAssumption = inputs.condAssumption;
        else
            restrictions.condAssumption = 'before';
        end
        
    else
        states = ones(nSteps,1);
        if isempty(inputs.states)
            restrictions.states = nan(nSteps,1);
        else
            if isscalar(inputs.states)
                restrictions.states = inputs.states(ones(1,nSteps));
            else
                if size(inputs.states,1) ~= nSteps
                    error([mfilename ':: The states input must either be empty, a scalar or a column vector with size nSteps.'])
                end
                restrictions.states = inputs.states;
            end
        end
    end
    
    % Get model properties
    endo = model.endo;
    res  = model.res;
    nRes = length(res);
    
    % Get deterministic exogenous vars
    if strcmpi(model.class,'nb_arima')
        constant = false; % Constant is in the observation equation if any in this case...
    else
        if isfield(options,'constant')
            constant = options.constant;
        else
            constant = []; % Not used in this case
        end
    end
    [X,exoWithoutDet] = nb_forecast.getDeterministic(options,inputs,nSteps,model.exo,constant);
    if condDistribution
        if isfield(inputs,'initPeriods')
            initPeriods = inputs.initPeriods;
        else
            initPeriods = 0;
        end
        X = nb_distribution.double2Dist(X); 
    end
    
    % Get endo restrictions
    ind           = ismember(condDBVars,endo);
    endoCondVars  = condDBVars(ind);
    [~,endo_d_id] = ismember(endoCondVars,condDBVars);
    endoData      = condDB(:,endo_d_id,:); % Pages represent mean
    nEndoVars     = size(endoData,2);
    if isempty(endoData)
       endo_id      = [];
       endoCondVars = {};
    else
        if condDistribution
            if all(size(inputs.sigma) == (nSteps + initPeriods)*nEndoVars)
                restrictions.covY     = inputs.sigma;
                restrictions.covYType = inputs.sigmaType;
            else
                error([mfilename ':: The sigma input must be a (nSteps + initPeriods)*nEndoVars x (nSteps + initPeriods)*nEndoVars double ('...
                                 int2str((nSteps + initPeriods)*nEndoVars) ' x ' int2str((nSteps + initPeriods)*nEndoVars) '), is '...
                                 int2str(size(inputs.sigma,1)) ' x ' int2str(size(inputs.sigma,2)) ])
            end
        end
       restrictions.type = 3;
       [~,endo_id]       = ismember(endoCondVars,endo);
    end
    
    n = nSteps - size(endoData,1); 
    if n > 0
        endoData = [endoData;nan(n,size(endoData,2),inputs.nPeriods)];
    end
    
    restrictions.Y        = endoData;
    restrictions.indY     = endo_id;
    restrictions.endo     = endo;
    restrictions.condEndo = endoCondVars;
    
    % Get exo restrictions (besides constant, time-trend and seasonals
    restrictions.exo = model.exo;
    if ~isempty(exoProj)
        if any(strcmpi(model.class,{'nb_sa','nb_fmsa'}))
            error([mfilename ':: The ''exoProj'' input is not supported for nb_sa or nb_fmsa models.'])
        end
    end
    
    if any(strcmpi(model.class,{'nb_sa','nb_fmsa'}))
        [~,indX] = ismember(exoWithoutDet,options(end).dataVariables);
        Xexo     = options(end).data(:,indX);
        if isempty(inputs.startInd)
            if inputs.nPeriods == 1
                Xexo = Xexo(end,:);
            else
                Xexo = Xexo(1:inputs.nPeriods,:);
            end
        else
            Xexo = Xexo(inputs.startInd:inputs.startInd+inputs.nPeriods-1,:);
        end
        if options(end).unbalanced
            % In case of unbalanced data, we may have that some
            % observables have one more observation, but this will
            % not always be the case, so set nan to zero. (The 
            % estimation results are also corrected for this case) 
            Xexo(isnan(Xexo)) = 0;
        end

        Xexo           = permute(Xexo,[3,2,1]);
        Xexo           = Xexo(ones(1,nSteps),:,:);
        restrictions.X = [X,Xexo];
    else
        if ~isempty(exoWithoutDet)
            if strcmpi(model.class,'nb_fm')
                exoData = getFactorsAndExogenous(model,inputs,condDB,condDBVars);
                if isempty(exoDataFact)
                    exoData = nan(nSteps,size(exoWithoutDet,2),inputs.nPeriods);
                end
            elseif strcmpi(model.class,'nb_ecm')
                [exoDataFound,exoFound] = getDiffAndLevel(exoWithoutDet,options,inputs,condDB,condDBVars);
                exoData                 = nan(nSteps,size(exoWithoutDet,2),inputs.nPeriods);
                if ~isempty(exoFound)
                    test = ismember(exoWithoutDet,exoFound);
                    if not(all(test)) && isempty(exoProj)
                        error([mfilename ':: All exogenous variables must be condition on. The following exogenous '...
                                         'variables has missing data; ' nb_cellstr2String(exoWithoutDet(~test),', ',' and ')])
                    end
                    [ind,loc]             = ismember(exoFound,exoWithoutDet);
                    exoData(:,loc(ind),:) = exoDataFound(:,ind,:);
                end
            else
                exoData       = nan(nSteps,size(exoWithoutDet,2),inputs.nPeriods);
                ind           = ismember(condDBVars,exoWithoutDet);
                exoCondVars   = condDBVars(ind);
                [ind,reorder] = ismember(exoWithoutDet,exoCondVars);
                if not(all(ind)) && isempty(exoProj)
                    error([mfilename ':: All exogenous variables must be condition on. The following exogenous '...
                                     'variables has missing data; ' nb_cellstr2String(exoWithoutDet(~ind),', ',' and ')])
                end
                [~,exo_d_id]              = ismember(exoCondVars,condDBVars);
                exoData(:,reorder(ind),:) = condDB(:,exo_d_id,:); % Pages represent mean
            end
            if softConditioning
                restrictions.X = [X(:,:,ones(1,nPages)),exoData];
            else
                restrictions.X = [X,exoData];
            end

            if restrictions.type ~= 3
                restrictions.type = 2;
            end

        else
            restrictions.X = X;
        end
    end
    
    % Get exogenous variables in the observation equation of ARIMA models
    % and univariate time-varying parameter models
    usv = false;
    if strcmpi(model.class,'nb_tvp')
        if strcmpi(options.prior.type,'usv')
            usv = true;
        end 
    end
    
    if strcmpi(model.class,'nb_arima') || usv
        
        exoObs     = model.factors;
        [Z,exoObs] = nb_forecast.getDeterministic(options,inputs,nSteps,exoObs);
        if ~isempty(exoObs)
            
            exoData       = nan(nSteps,size(exoObs,2),size(condDB,3));
            ind           = ismember(condDBVars,exoObs);
            exoCondVars   = condDBVars(ind);
            [ind,reorder] = ismember(exoObs,exoCondVars);
            if not(all(ind)) && isempty(exoProj)
                error([mfilename ':: All exogenous variables must be condition on. The following exogenous '...
                                 'variables has missing data; ' nb_cellstr2String(exoObs(~ind),', ',' and ')])
            end
            [~,exo_d_id]              = ismember(exoCondVars,condDBVars);
            exoData(:,reorder(ind),:) = condDB(:,exo_d_id,:); % Pages represent mean
            if softConditioning
                restrictions.Z = [Z(:,:,ones(1,nPages)),exoData];
            else
                restrictions.Z = [Z,exoData];
            end
            if restrictions.type ~= 3
                restrictions.type = 2;
            end

        else
            restrictions.Z = Z;
        end
        restrictions.exoObs = model.factors;
        if isempty(model.exo)
            restrictions.X = zeros(nSteps,0,inputs.nPeriods);
        end
        
    end
    
    % Get shocks restrictions
    [ind,shock_id]       = ismember(condDBVars,res);
    shock_id             = shock_id(ind);
    restrictions.res     = res;
    restrictions.condRes = res(shock_id);
    if isa(condDB,'nb_distribution')
        
        if strcmpi(model.type,'nb')
            if iscell(model.A)
                vcv = model.vcv;
            else
                vcv = {model.vcv};
            end
        else % Dynare
            vcv = {model.vcv};
        end
        
        shockData(nSteps,nRes,inputs.nPeriods) = nb_distribution;
        for ii = 1:length(res)
            for tt = 1:size(shockData,1)
                sig                = sqrt(diag(vcv{states(tt)}));
                shockData(tt,ii,:) = nb_distribution('type','normal','parameters',{0,sig(ii)}); % ~N(0,sig(ii)), here I assume that the residuals are uncorrelated!!!
            end
        end
        indD = initPeriods+1:size(condDB,1);
        
    else
        shockData = zeros(nSteps,nRes,inputs.nPeriods);
        indD      = 1:size(shockData,1);
    end
    if ~isempty(shock_id)
        
        if any(strcmpi(model.class,{'nb_sa','nb_fmsa','nb_midas'}))
            error([mfilename ':: Cannot condition on shocks when the model is of type nb_sa, nb_fmsa or nb_midas'])
        end        
        [~,shock_d_id]          = ismember(condDBVars(ind),condDBVars);
        shockData(:,shock_id,:) = condDB(indD,shock_d_id,:); % Pages represent mean
        if restrictions.type ~= 3
            restrictions.type = 2;
        end
        
    end
    
    % Interpret the shockProps input to see if some of the shocks needs to
    % be activated to match the endogenous variables
    if ~isempty(endoData)
        
        if inputs.kalmanFilter
            if ~isempty(shock_id)
                error([mfilename ':: Cannot condition on shocks when the kalmanFilter input is set to true.'])
            end
        else
            if ~isfield(shockProps,'Name')
                error([mfilename ':: When adding endogenous restrictions the input shockProps must be given as a struct with fields Name and Periods.'])
            end

            if ~isfield(shockProps,'Periods')
                error([mfilename ':: When adding endogenous restrictions the input shockProps must be given as a struct with fields Name and Periods.'])
            end

            if length(shockProps) < size(endoData,2)
                error([mfilename ':: The number of shocks is less than the number of endogenous variables you condition on.'])
            end

            for ii = 1:length(shockProps)

                name    = shockProps(ii).Name;
                periods = shockProps(ii).Periods;
                ind     = strcmp(name,res);

                if all(~ind)
                   error([mfilename ':: The shock ' name ' is not part of the model, but you have given it to the shockProps input!']) 
                end

                if isnan(periods)
                    if isa(condDB,'nb_distribution')
                        shockData(:,ind,:) = nb_distribution('type','constant','parameters',{nan}); 
                    else
                        shockData(:,ind,:) = nan; 
                    end
                elseif periods > 0
                    if isa(condDB,'nb_distribution')
                        shockData(1:periods,ind,:) = nb_distribution('type','constant','parameters',{nan}); 
                    else
                        shockData(1:periods,ind,:) = nan;
                    end
                end

            end
            
        end
        
    end
    
    restrictions.E = shockData;

    % Manually set covariance matrices
    if isfield(inputs,'sigma')
        restrictions.covY = inputs.sigma;
    end
    
    if isfield(inputs,'sigmaX')
        restrictions.covX = inputs.sigmaX;
    end
    
    if isfield(inputs,'sigmaE')
        restrictions.covE = inputs.sigmaE;
    end
    
    % Give noise about model class
    restrictions.class = model.class;
    
    % Which variables should be projected with exoProj method?
    if ~isempty(exoProj)
        restrictions.indExo = any(isnan(restrictions.X),1);
        if isfield(restrictions,'exoObs')
            restrictions.indExoObs = any(isnan(restrictions.Z),1);
        end
    end
    
    % Are we doing a Kalman filter? In this case we also store the history
    if inputs.kalmanFilter
        
        if ~any(strcmpi(restrictions.class,{'nb_var','nb_pitvar'}))
            error(['The kalmanFilter options can only be set to true when the object ',...
                   'is of class nb_var or nb_pitvar']);
        end
        restrictions.kalmanFilter = true;
        
        % Get historical data
        dep      = [options.dependent, options.block_exogenous];
        [~,indY] = ismember(dep,options.dataVariables);
        myHist   = options.data(options.estim_start_ind:options.estim_end_ind,indY);
        exoWithoutDet      = options.exogenous;
        pred     = nb_cellstrlag(dep,options.nLags + 1,'varFast');
        ind      = ~ismember(exoWithoutDet,pred);
        exoWithoutDet      = exoWithoutDet(ind); % Remove lagged dependent from rhs variables in estimation
        [~,indX] = ismember(exoWithoutDet, options.dataVariables);
        mxHist   = options.data(options.estim_start_ind:options.estim_end_ind,indX);
        if options.time_trend
            mxHist = [transpose(1:size(mxHist,1)),mxHist];
        end
        if options.constant
            mxHist = [ones(size(mxHist,1),1),mxHist];
        end
        restrictions.YHist = myHist;
        restrictions.XHist = mxHist;
        
    else
        restrictions.kalmanFilter = false;
    end
    
end

%==========================================================================
% SUB
%==========================================================================
function exoData = getFactorsAndExogenous(model,inputs,condDB,condDBVars)

    [s1,~,s3]     = size(condDB);
    obs           = model.observables;
    [ind,reorder] = ismember(obs,condDBVars);
    if not(all(ind))
        if ~isempty(inputs.exoProj)
            exoData = [];
            return
        else
            error([mfilename ':: All observables must be condition on. The following observables have missing data; ' toString(obs(~ind))])
        end
    end
    obsData = condDB(:,reorder,:);
    const   = model.F';
    const   = const(ones(1,s1),:,ones(1,s3));
    obsData = obsData - const;
    exoData = nan(s1,length(model.factors),s3);
    G       = model.G;
    for ii = 1:s3
        exoData(:,:,ii) = obsData(:,:,ii)*G;
    end
    
end

%==========================================================================
function [exoData,exoNames] = getDiffAndLevel(exo,opt,inputs,condDB,condDBVars)

    [s1,~,s3] = size(condDB);
    exoNames  = {};
   
    indL            = ismember(exo,strcat(opt.endogenous,'_lag1'));
    exoL            = strrep(exo(indL),'_lag1','');
    indD            = ~cellfun(@isempty,regexp(exo,'^diff_'));
    exoD            = exo(indD);
    exoDB           = regexprep(exoD,'_lag[0-9]+$','');
    exoDB           = regexprep(exoDB,'^diff_','');
    keep            = ismember(exoDB,exoL);
    exoD            = exoD(keep);
    exoDB           = exoDB(keep);
    [indLM,reorder] = ismember(exoL,condDBVars); 
    if all(indLM)
        
        % Get historical data on levels
        [~,indE] = ismember(exoL,opt.dataVariables);
        X        = opt.data(:,indE);
        
        % Construct diff variables
        nExoD     = length(exoD);
        exoDataEL = nan(s1,nExoD,s3);
        exoDataL  = condDB(:,reorder,:);
        nSteps    = size(condDB,1);
        if isempty(inputs.endInd)
            start = inputs.startInd + 1;
        else
            start = inputs.startInd+1:inputs.endInd;
        end
        
        for ee = 1:nExoD
            for ii = 1:length(start)
                nLag = regexp(exoD{ee},'_lag[0-9]+$','match');
                if isempty(nLag)
                    nLag = 0;
                else
                    nLag = str2double(regexp(nLag{1},'[0-9]+$','match'));
                end
                indB = strcmp(exoDB{ee},exoL);
                if nLag >= nSteps
                    correct = (nLag - nSteps) + 1;
                else
                    correct = 1;
                end
                temp               = [X(start(ii)-nLag-1:start(ii)-correct,indB);exoDataL(1:end-nLag,indB,ii)];
                exoDataEL(:,ee,ii) = diff(temp,1);
            end
        end
        
        % Lag level variables
        for ii = 1:length(start)
            exoDataL(:,:,ii)  = [X(start(ii)-1:start(ii)-1,:);exoDataL(1:end-1,:,ii)];
        end
        
        % Add to conditional data + reorder stuff correctly
        exoData  = [exoDataL,exoDataEL];
        exoNames = [strcat(exoL,'_lag1'),exoD];
        
    else
        
        % Get non-lagged diff variables
        exoDA         = exoD;
        exoD          = unique(regexprep(exoD,'_lag[0-9]+$',''));
        [ind,reorder] = ismember(exoD,condDBVars);
        if not(all(ind))
            if ~isempty(inputs.exoProj)
                exoData = [];
                return
            else
                error([mfilename ':: Either all the level variables or all the non-lagged diff variables must be provided in the condDB input. '...
                                 'Missing (level); '  toString(exoL(~indLM)) '. Missing (diff); ' toString(exoD(~ind))])
            end
        end
        
        % Get historical data on levels
        exoLL    = strcat(exoL,'_lag1'); 
        [~,indE] = ismember(exoLL,opt.dataVariables);
        XL       = opt.data(:,indE);
        
        % Get historical data on diff
        [~,indE] = ismember(exoD,opt.dataVariables);
        X        = opt.data(:,indE);
        
        % Construct lagged diff variables
        indR     = ismember(exoDA,exoD);
        exoDL    = exoDA(~indR);
        exoDB    = regexprep(exoDL,'_lag[0-9]+$','');
        nExoDL   = length(exoDL);
        exoDataE = nan(s1,nExoDL,s3);
        exoData  = condDB(:,reorder,:);
        nSteps   = size(condDB,1);
        if isempty(inputs.endInd)
            start = inputs.startInd + 1;
        else
            start = inputs.startInd+1:inputs.endInd;
        end
        for ee = 1:nExoDL
            nLag = str2double(regexp(exoDL{ee},'[0-9]+$','match'));
            indB = strcmp(exoDB{ee},exoD);
            if nLag >= nSteps
                correct = (nLag - nSteps) + 1;
            else
                correct = 1;
            end
            for ii = 1:length(start)
                exoDataE(:,ee,ii) = [X(start(ii)-nLag:start(ii)-correct,indB);exoData(1:end-nLag,indB,ii)]; % Lagged diff
            end
        end
        
        % Construct level variables (lagged one period)
        nExoL     = length(exoL);
        exoDataEL = nan(s1,nExoL,s3);
        exoDB     = strcat('diff_',exoL);
        for ee = 1:nExoL
            for ii = 1:length(start)
                indB              = strcmp(exoDB{ee},exoD);
                temp              = [X(start(ii)-1,indB);exoData(1:end-1,indB,ii)]; % Lagged diff
                exoDataEL(:,ee,ii) = nb_undiff(temp,XL(start(ii)-1,ee),1);          % Undiff using lagged level prev period 
            end
        end
        
        % Add to conditional data + reorder stuff correctly
        exoData  = [exoData,exoDataE,exoDataEL];
        exoNames = [exoD,exoDL,exoLL];
               
    end
    
    % Get the data on the rest of the exogenous
    exoRest         = exo(not(indL|indD)); % The series that aren't lagged or differenced!
    [test,reorderR] = ismember(exoRest,condDBVars);
    if all(test)
        exoDataRest = condDB(:,reorderR,:);
        exoData     = [exoData,exoDataRest];
        exoNames    = [exoNames,exoRest];
    else
        
        [test,loc] = ismember(opt.exogenousOrig,condDBVars);
        if any(~test) 
           error([mfilename ':: The following variables are exogenous, but are not assing any conditional information; ' toString(opt.exogenousOrig(~test))])
        end
        
        % The exoLag input has been used
        [~,indE] = ismember(opt.exogenousOrig,opt.dataVariables);
        for ii = 1:length(opt.exogenousOrig)
            
            if isnumeric(opt.exoLags)
                maxLag = opt.exoLags(ii);
            else
                maxLag = max(opt.exoLags{ii});
            end
            
            if isempty(inputs.endInd)
                start = inputs.startInd + 1;
            else
                start = inputs.startInd+1:inputs.endInd;
            end
            
            if maxLag >= nSteps
                correct = (maxLag - nSteps) + 1;
            else
                correct = 1;
            end
            
            % Construct lags recursivly
            restExoDB = nan(s1,maxLag+1,s3);
            for pp = 1:length(start)
                histDB            = opt.data(start(pp)-maxLag:start(pp)-correct,indE(ii));
                conDBExo          = condDB(:,loc(ii),pp);
                fullDB            = [histDB;conDBExo];
                lagDB             = nb_mlag(fullDB,maxLag);
                restExoDB(:,:,pp) = [conDBExo,lagDB(maxLag+1:end,:)];
            end
            lagN     = nb_cellstrlag(opt.exogenousOrig(ii),maxLag);
            exoData  = [exoData,restExoDB]; %#ok<AGROW>
            exoNames = [exoNames,opt.exogenousOrig(ii),lagN]; %#ok<AGROW>
            
        end
        
    end
        
    % Reorder the data
%     allExo = [opt.exogenous,opt.rhs];
%     ind    = ismember(exo,allExo);
%     if any(~ind)
%         % Correct for diff of endogenous is forced into the solution
%         exoDataT         = exoData;
%         exoData          = zeros(s1,length(exo),s3);
%         [t,indR]         = ismember(exo,exoNames);
%         exoDataT         = exoDataT(:,indR(t),:);
%         exoData(:,ind,:) = exoDataT;
%     else
%         [~,indR] = ismember(exo,exoNames);
%         exoData  = exoData(:,indR,:);
%     end
end

function y0 = drawNowcast(y0,options,results,model,inputs,iter)
% Syntax:
%
% y0 = nb_forecast.drawNowcast(options,results,model,inputs,iter)
%
% Description:
%
% Produce density nowcast.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    switch lower(options.missingMethod)        
        case 'forecast'
            y0 = forecastMethod(y0,options,model,inputs,iter);
        case 'ar'
            y0 = arMethod(y0,options,model,inputs);
        case 'copula'
            y0 = copulaMethod(y0,options,results,model,inputs,iter);
        case 'kalman'
            y0 = kalmanMethod(y0,options,results,model,inputs,iter);
        case 'kalmanfilter'
            y0 = kalmanFilterMethod(y0,options,results,model,inputs,iter);
    end

end

%==========================================================================
function y0 = forecastMethod(y0,options,model,inputs,iter)
% Here we use a conditional forecast routines to draw from the distribution
% of the missing observation given the mean parameters or one draw from the
% distribution of the parameters.
%
% Caution : If missingMethod is Kalman we take the mean from the smoothed
%           estimates and not from the conditional forecast.

    if inputs.draws == 1
        
        % Add more missing periods
        [noMissing,nSteps] = getMissing(options);
        if noMissing
            return
        end
        [~,locV] = ismember(model.endo,options.dataVariables);
        y0       = options.data(options.estim_end_ind - nSteps + 1:options.estim_end_ind,locV)';

    else
        
        regimeDraws = inputs.regimeDraws;
        if ~iscell(model.A)
            regimeDraws = 1;
        end

        % Which observations are missing
        [noMissing,nSteps,allVars,missing,missingT,~] = getMissing(options);
        if noMissing
            % No missing observation to produce nowcast on
            y0 = y0(:,:,ones(1,inputs.draws));
            return
        end

        % Find conditional information
        numVars     = size(missing,2);
        mSteps      = nSteps + options.nLags + 1;
        mInd        = [missingT(:)',false(1,(mSteps - 1)*numVars)];
        fullVars    = [allVars,nb_cellstrlag(allVars,mSteps,'varFast')]; 
        missingVars = fullVars(mInd);

        % Adjust mean given conditional information
        indM   = ismember(model.endo,missingVars);
        muCond = y0(indM,1,:); % Center around estimates
        if inputs.draws == 1
            y0(indM) = muCond;
        else

            % Build covariance matrix between the forecasted, conditional and
            % historical variables
            model = nb_forecast.getModelMatrices(model,iter,false,options,nSteps);
            A     = model.A;
            B     = model.B;
            C     = model.C;
            vcv   = model.vcv;
            if isfield(model,'Q')
                [A,B,C,vcv] = ms.integrateOverRegime(model.Q,A,B,C,vcv);
            end
            [~,c] = nb_calculateMoments(A,B,C,vcv,0,0,mSteps,'covariance');
            nDep  = length(allVars);
            c     = c(1:nDep,1:nDep,:);
            R     = nb_constructStackedCorrelationMatrix(c);

            % Now we need to partition the correlation matrix
            hInd = mInd(:,1:numVars*nSteps);
            indC = ~mInd(:,1:numVars*nSteps);
            R11  = R(~indC,~indC);
            R12  = R(~indC,indC);
            R21  = R(indC,~indC);
            R22  = R(indC,indC);

            % Adjust correlation matrix
            RCond  = R11 - (R12/R22)*R21;

            % Draw nowcast
            y0           = y0(:,:,ones(1,inputs.draws));
            y0(hInd,:,:) = permute(nb_mvnrand(inputs.draws*regimeDraws,1,muCond',RCond),[2,3,1]);

        end

        % Remove not necessary observations
        nLags = length(model.endo)/length(options.dependent);
        nTest = size(y0,1)/length(options.dependent);
        if nLags < nTest
            tested  = [allVars,nb_cellstrlag(allVars,nTest-1,'varFast')]; 
            indKeep = ismember(tested,model.endo);
            y0      = y0(indKeep,:,:);
        end
        
        % Append more history
        if nSteps > 1
            [~,locV]        = ismember(model.endo(1:numVars),options.dataVariables);
            y0Hist          = flip(options.data(options.estim_end_ind - 2*nSteps + 2:options.estim_end_ind-nSteps,locV)',2);
            y0Hist          = y0Hist(:);
            y0Hist          = y0Hist(:,:,ones(1,inputs.draws));
            y0Temp          = nan(size(y0,1),nSteps,size(y0,3));
            y0Temp(:,end,:) = y0;  
            for ii = nSteps-1:-1:1
                s              = numVars*ii + 1;
                sH             = numVars*(ii-1) + 1;
                y0Temp(:,ii,:) = vertcat(y0Temp(s:end,ii+1,:),y0Hist(sH:sH+numVars-1,:,:));
            end
            y0 = y0Temp;
        end
    
    end
       
end


%==========================================================================
function y0 = kalmanMethod(y0,options,results,model,inputs,iter)
% Only handle point forecast case.
  
    % Add more missing periods
    if strcmpi(options.class,'nb_fmdyn')   
        dep = options.observables;
    else
        dep = options.dependent;
        if isfield(options,'block_exogenous')
            dep = [dep,options.block_exogenous];
        end
    end
    nSteps = nb_forecast.checkForMissing(options,inputs,dep);
    if nSteps == 0
        return
    end
    [~,locV]  = ismember(model.endo,results.smoothed.variables.variables);
    dataStart = nb_date.date2freq(options.dataStartDate);
    if isfield(results,'filterStartDate')
        estStart  = dataStart + (options.estim_start_ind - 1);
        filtStart = nb_date.toDate(results.filterStartDate,dataStart.frequency);
        filtLag   = filtStart - estStart;
    else
        filtLag = 0;
    end
    if options.recursive_estim
        T = options.recursive_estim_start_ind - options.estim_start_ind + iter - filtLag;
    else
        T = options.estim_end_ind - options.estim_start_ind + 1 - filtLag;
    end
    y0 = results.smoothed.variables.data(T-nSteps+1:T,locV,iter)';
        
    if inputs.draws > 1
        y0 = y0(:,:,ones(1,inputs.draws));
        warning([mfilename ':: Cannot handle draw from the distribution ',...
            'from the smoothed variables yet, no nowcast uncertainty assumed. ',...
            'Set parameterDraws > 1 to sample from the nowcast distribution. ',...
            'Using point estimate for nowcast!'])
    end
    
end

%==========================================================================
function y0 = kalmanFilterMethod(y0,options,results,model,inputs,iter)
% Take nowcast from kalman filter. Only supported for point forecast for
% now

    % Get number of missing
    [noMissing,nMissing] = getMissing(options);
   
    % Get nowcast
    if inputs.draws == 1
        
        % In this case we have stored the historical or smoothed mean
        % estimates from the kalman filter in options.data, so we can get 
        % it from there 
        if noMissing
            return
        end
        [~,locV] = ismember(model.endo,options.dataVariables);
        y0       = options.data(options.estim_end_ind - nMissing + 1:options.estim_end_ind,locV)';
        
    else
        
        % In this case we need to get a smoothed estimate of the std/var of
        % the nowcast during filtering. This is not yet finished...
        error('Setting missingMethod to ''kalmanFilter'' is not yet supported when draws > 1.')
        
    end
     
end


%==========================================================================
function y0 = arMethod(y0,options,model,inputs)
% Draw from the distribution of the missing observation by doing density
% forecasting from the AR models. These distribution will not necessary 
% be in line with the distribution of the missing observation of the 
% model actually used. But this approach is very fast.

    regimeDraws = inputs.regimeDraws;
    if ~iscell(model.A)
        regimeDraws = 1;
    end

    y0 = y0(:,:,ones(1,inputs.draws*inputs.parameterDraws*regimeDraws));

    % Set up ARIMA models
    finish                = options.estim_end_ind;
    tempOpt               = nb_arimaEstimator.template();
    tempOpt.integration   = nan;
    tempOpt.MA            = 0;
    tempOpt.doTests       = false;
    tempOpt.maxAR         = 10;
    tempOpt.criterion     = 'sic';
    tempOpt.data          = options.data;
    tempOpt.dataVariables = options.dataVariables;
    tempOpt.dataStartDate = options.dataStartDate;

    % Estimate AR model and forecast
    forecastVars = options.missingVariables;
    indRemove    = cellfun(@(x)strfind(x,'_lag'),forecastVars,'UniformOutput',false);
    indRemove    = cellfun(@isempty,indRemove);
    forecastVars = forecastVars(indRemove);
    missing      = options.missingData(1:finish,indRemove);
    for ii = 1:length(forecastVars)
        estEnd = find(~missing(:,ii),1,'last');
        if estEnd ~= finish
            tempOpt.dependent      = forecastVars(ii);
            tempOpt.estim_end_ind  = estEnd;
            [res,tempOpt]          = nb_arimaEstimator.estimate(tempOpt);
            model                  = nb_arima.solveNormal(res,tempOpt);
            inputsF                = nb_forecast.defaultInputs(true);
            inputsF.draws          = inputs.draws*regimeDraws;
            inputsF.parameterDraws = inputs.parameterDraws;
            inputsF.parallel       = true; % To prevent waitbar!!!
            nSteps                 = finish - estEnd;
            fcst                   = nb_forecast(model,tempOpt,res,estEnd+1,[],nSteps,inputsF,[],{},[]);
            
            % Assign to data property to use for full sample estimation
            indV         = strcmpi(fcst.dependent,model.endo);
            y0(indV,1,:) = permute(fcst.data(end,:,1:end-1),[2,1,3]);
        end
    end

end

%==========================================================================
function y0 = copulaMethod(y0,options,results,model,inputs,iter)

    error([mfilename ':: The missing observation method ''copula'' is not ready to be used for density nowcast.'])

end

%==========================================================================
function [noMissing,nSteps,allVars,missing,missingT,lastMout] = getMissing(options)

    % Which observations are missing
    missing     = options.missingData(options.estim_start_ind:end,:);
    allMissing  = all(missing,2);
    anyMissing  = any(missing,2);
    lastMissing = find(~allMissing & anyMissing);
    noMissing   = false;
    if isempty(lastMissing)
        % No missing observation to produce nowcast on
        noMissing = true;
        return
    else
        lastM    = lastMissing(end);
        lastMout = lastM + options.estim_start_ind - 1;
        if options.estim_end_ind ~= lastMout
            % The missing observation is not at the end, so we do not
            % handle it
            noMissing = true;
            return
        end
        
        % Remove missing observation in the middle of the sample
        if ~isscalar(lastMissing)
            for ii = length(lastMissing)-1:-1:1
                if lastM - lastMissing(ii) > 1
                    ii = ii + 1; %#ok<FXSET>
                    break
                end
                lastM = lastMissing(ii);
            end
            lastMissing = lastMissing(ii:end);
        end
    end
    missing  = missing(lastMissing,:);
    nSteps   = size(missing,1);
    if nargout > 2
    
        allVars  = options.missingVariables;
        indKeep  = cellfun(@(x)strfind(x,'_lag'),allVars,'UniformOutput',false);
        indKeep  = cellfun(@isempty,indKeep);
        allVars  = allVars(indKeep);
        missing  = missing(:,indKeep);
        indKeep  = ~ismember(allVars,options.exogenous);
        allVars  = allVars(indKeep);
        missing  = missing(:,indKeep);
        missingT = flip(missing,1)';
        
    end
    
end

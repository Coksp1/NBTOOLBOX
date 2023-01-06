function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_tslsEstimator.estimate(options)
%
% Description:
%
% Estimate a model with two stage least squares.
% 
% Input:
% 
% - options  : A struct on the format given by nb_tslsEstimator.template.
%              See also nb_tslsEstimator.help.
% 
% Output:
% 
% - result  : A struct with the estimation results.
%
% - options : The return model options, can be updated.
%
% See also:
% nb_tslsEstimator.print, nb_tslsEstimator.help, nb_tslsEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end

    % Get the estimation options

    tempOpt = options;
    if isempty(tempOpt.data)
        error([mfilename ':: Cannot estimate without data.'])
    end

    if tempOpt.recursive_estim

        % When we are doing recursive estimation we don't
        % need the fancy printouts, so we write the 
        % estimation more compact
        options = struct('mainEq',[]);
        results = struct('mainEq',[]);
        [results.mainEq,options.mainEq] = recursiveEstimation(tempOpt);

    else % Normal estimation

        results = struct();
        options = struct();
        
        tempDep = tempOpt.dependent;
        if isempty(tempDep)
            error([mfilename ':: You must add the left side variable of the equation to dependent field of the options property.'])
        end

        % Set up the first stage of the estimation. I.e. the
        % instrument variable estimation
        %------------------------------------------------------
        tempExo   = tempOpt.exogenous;
        tempEndo  = tempOpt.endogenous;
        tempInstr = tempOpt.instruments;
        numEndo   = length(tempEndo);

        if numEndo == 0
            error([mfilename ':: You must declare some endogenous variables.'])
        end

        % Get valid sample
        %-----------------
        allVars     = [tempDep,tempExo,tempEndo,nb_nestedCell2Cell(tempInstr(2:2:end))];
        [~,indV]    = ismember(allVars,tempOpt.dataVariables);
        V           = tempOpt.data(:,indV);
        [tempOpt,~] = nb_estimator.testSample(tempOpt,V);
        start       = tempOpt.estim_start_ind;
        finish      = tempOpt.estim_end_ind;
        
        % Estimate each of the first stage equation in turn
        %--------------------------------------------------
        % Check instrumenst
        ind = cellfun(@isempty,tempInstr(2:2:end));
        if any(ind)
            endo = tempInstr(1:2:end);
            error([mfilename ':: When doing TSLS all the endogenous variables must be assign at least one instrument' char(10)...
                             'The following endogenous variables are missing instruments; ' toString(endo(ind))])
        end
        
        predData = nan(finish - start + 1,numEndo);
        for jj = 1:numEndo

            ind = find(strcmp(tempEndo{jj},tempInstr),1);
            if isempty(ind)
                error([mfilename ':: Could not find the instruments for the endogenous variable ' tempEndo{jj}])
            end
            instrExo = tempInstr{ind + 1};
            if ischar(instrExo)
                instrExo = cellstr(instrExo);
            elseif ~iscellstr(instrExo)
                error([mfilename ':: If the instruments are provided as a nested cell. All the elements must be of class cellstr.'])
            end

            if isempty(instrExo)
                error([mfilename ':: The instruments for the endogenous variable ' tempEndo{jj} ' can not be empty.'])
            end

            % Set first stage estimation options
            tempOptFirstStage            = tempOpt;
            tempOptFirstStage.dependent  = tempEndo(jj);
            tempOptFirstStage.exogenous  = instrExo;
            tempOptFirstStage.endogenous = {};
            
            % Estimate the first stage equation
            [firstStageResults,firstStageOptions] = nb_olsEstimator.estimate(tempOptFirstStage);

            % Assign results
            results.(['firstStageEq' int2str(jj)]) = firstStageResults;
            options.(['firstStageEq' int2str(jj)]) = firstStageOptions;
            
            % Get predicted variable
            predData(:,jj) = firstStageResults.predicted;
            
        end

        % Get the instrumented variables
        tempInstrumented = strcat('Predicted_',tempEndo);
        tempData         = [tempOpt.data(start:finish,:),predData];

        % Get the (now) exogenous variables
        tempExo = [tempOpt.exogenous,tempInstrumented];

        % Set first stage estimation options
        tempOptSecondStage                  = tempOpt;
        tempOptSecondStage.data             = tempData;
        tempOptSecondStage.dataStartDate    = nb_dateplus(tempOpt.dataStartDate,start - 1);
        tempOptSecondStage.dataVariables    = [tempOpt.dataVariables,tempInstrumented];
        tempOptSecondStage.exogenous        = tempExo;
        tempOptSecondStage.estim_start_ind  = 1;
        tempOptSecondStage.estim_end_ind    = size(tempData,1);
        tempOptSecondStage.endogenous       = {};
        tempOptSecondStage.modelSelection   = '';

        % Estimate the second stage equation
        [res,opt] = nb_olsEstimator.estimate(tempOptSecondStage);
        
        % Assign results
        results.('mainEq') = res;
        options.('mainEq') = opt;

    end
    options.recursive_estim = false;
    
    fields = fieldnames(results);
    eTime  = toc(tStart);
    for ii = 1:length(fields)
        results.(fields{ii}).elapsedTime = eTime;
    end
    options.estimator    = 'nb_tslsEstimator';
    options.estimType    = 'classic';
    options.estim_method = 'tsls';

end

%==================================================================
% SUB
%==================================================================
function [res,tempOpt] = recursiveEstimation(tempOpt)
% Recursive estimation using nb_tsls

    tempData = tempOpt.data;
    tempDep  = tempOpt.dependent;
    tempExo  = tempOpt.exogenous;
    if isempty(tempDep)
        error([mfilename ':: You must add the left side variable of the equation to dependent field of the options property.'])
    end
    
    % Add seasonals
    %----------------------
    indS = 0;
    if ~isempty(tempOpt.seasonalDummy)
            
        startDate = tempOpt.dataStartDate;
        ind1      = ~isempty(strfind(startDate,'Q'));
        ind2      = ~isempty(strfind(startDate,'K'));
        indS      = ind1 || ind2;
        frequency = 4;
        if not(indS)
            indS       = ~isempty(strfind(startDate,'M'));
            frequency = 12;
        end
        if indS

            % Create seasonals
            period    = str2double(startDate(6:end));
            T         = size(tempData,1) + period - 1;
            seasonals = nb_seasonalDummy(T,frequency,tempOpt.seasonalDummy);
            seasonals = seasonals(period:end,:);

            % Add to data
            tempData              = [tempData,seasonals];
            tempOpt.data          = tempData;
            seasVars              = strcat('Seasonal_',cellstr(int2str([1:frequency-1]'))'); %#ok<NBRAK>
            tempOpt.dataVariables = [tempOpt.dataVariables, seasVars];

            % Add to exogenous variables 
            tempExo           = [seasVars,tempExo];
            tempOpt.exogenous = tempExo;

        end

    end

    % Set up the first stage of the estimation. I.e. the
    % instrument variable estimation
    %------------------------------------------------------
    tempEndo  = tempOpt.endogenous;
    tempInstr = tempOpt.instruments;
    numEndo   = length(tempEndo);

    if numEndo == 0
        error([mfilename ':: You must declare some endogenous variables.'])
    end

    if ~isempty(tempOpt.estim_types) % Not time-series
        error([mfilename ':: Recursive estimation is only supported for time-series.'])
    end

    if ~isempty(tempOpt.modelSelection)
        error([mfilename ':: Recursive estimation is not supported for the model selection option; ' tempOpt.modelSelection])
    end

    % Get the estimation data
    %--------------------------------------------------
    startInd = tempOpt.estim_start_ind;
    if isempty(startInd)
        startInd = 1;
    end
    endInd = tempOpt.estim_end_ind;
    if isempty(endInd)
        endInd = size(tempOpt.data,1);
    end
    [~,indY] = ismember(tempDep,tempOpt.dataVariables);
    y        = tempData(startInd:endInd,indY);
    [~,indX] = ismember(tempExo,tempOpt.dataVariables);
    X        = tempData(startInd:endInd,indX);
    [~,indZ] = ismember(tempEndo,tempOpt.dataVariables);
    Z        = tempData(startInd:endInd,indZ);
    if isempty(y)
        error([mfilename ':: The selected sample cannot be empty.'])
    end
    
    % Get instruments as a cell of doubles (also include seasonals if wanted)
    inst = cell(1,numEndo);
    for jj = 1:numEndo

        indI = find(strcmp(tempEndo{jj},tempInstr),1);
        if isempty(indI)
            error([mfilename ':: Could not find the instruments for the endogenous variable ' tempEndo{jj}])
        end
        instrExo = tempInstr{indI + 1};
        if ischar(instrExo)
            instrExo = cellstr(instrExo);
        elseif ~iscellstr(instrExo)
            error([mfilename ':: If the instruments are provided as a nested cell. All the elements must be of class cellstr.'])
        end

        if isempty(instrExo)
            error([mfilename ':: The instruments for the endogenous variable ' tempEndo{jj} ' can not be empty.'])
        end

        indI = ismember(tempOpt.dataVariables,instrExo);
        if indS % Include seasonals
            inst{jj} = [seasonals(startInd:endInd,:),tempData(startInd:endInd,indI)];
        else
            inst{jj} = tempData(startInd:endInd,indI);
        end

    end

    % Secure that the data is balanced
    testData = [y,X,Z,inst{:}];
    testData = testData(:);
    if any(isnan(testData))
        error([mfilename ':: The estimation data is not balanced.'])
    end

    % Check the regressors
    if size(Z,2) == 0 && size(X,2) == 0 && ~tempOpt.constant && ~tempOpt.time_trend
        error([mfilename ':: You must select some regressors.'])
    end

    if any(all(diff(X,1) == 0,1))
        error([mfilename ':: One or more of the selected exogenous variables is/are constant. '...
                         'Use the constant option instead.'])
    end

    % Check the sample
    numCoeff = size(X,2) + size(Z,2) + tempOpt.constant + tempOpt.time_trend;
    T        = size(y,1);
    if isempty(tempOpt.rollingWindow)
    
        if isempty(tempOpt.recursive_estim_start_ind)
            start = tempOpt.requiredDegreeOfFreedom + numCoeff;
            tempOpt.recursive_estim_start_ind = start + startInd - 1;
        else
            start = tempOpt.recursive_estim_start_ind - startInd + 1;
            if start < tempOpt.requiredDegreeOfFreedom + numCoeff
                error([mfilename ':: The start period (' int2str(tempOpt.recursive_estim_start_ind) ') of the recursive estimation is '...
                    'less than the number of degrees of fredom that is needed for estimation (' int2str(tempOpt.requiredDegreeOfFreedom + numCoeff) ').'])
            end
        end
        iter = T - start + 1;
        if iter < 1
            error([mfilename ':: The sample is too short for recursive estimation. '...
                'At least ' int2str(tempOpt.requiredDegreeOfFreedom) ' degrees of freedom are required. '...
                'Which require a sample of at least ' int2str(start) ' observations.'])
        end
        ss = ones(1,iter);
        
    else
        
        if isempty(tempOpt.recursive_estim_start_ind)
            start = tempOpt.rollingWindow;
        else
            start = tempOpt.recursive_estim_start_ind;
        end
        if tempOpt.requiredDegreeOfFreedom + numCoeff > start
            error([mfilename ':: The rolling window  length is to short. '...
                'At least ' int2str(tempOpt.requiredDegreeOfFreedom) ' degrees of freedom are required. '...
                'Which require a window of at least ' int2str(tempOpt.requiredDegreeOfFreedom + numCoeff) ' observations.'])
        end
        tempOpt.recursive_estim_start_ind = start + startInd - 1;
        iter = T - start + 1;
        if iter < 1
            error([mfilename ':: The rolling window length is longer than the estimation period.']);
        end
        ss = 1:iter;

    end
    
    % Estimate the model recursively
    %--------------------------------------------------
    numDep            = size(y,2);
    
    % Estimate the first stage
    nzvar             = size(Z,2);
    zpred             = nan(T,nzvar,iter);
    firstStage(nzvar) = struct('beta',[],'stdBeta',[],'sigma',[]);
    const             = tempOpt.constant;
    timeTrend         = tempOpt.time_trend;
    stdType           = tempOpt.stdType;
    for eq = 1:nzvar
    
        instT        = inst{eq};
        numExoFS     = size(instT,2) + tempOpt.constant + tempOpt.time_trend;
        betaFS       = nan(numExoFS,numDep,iter);
        stdBetaFS    = nan(numExoFS,numDep,iter);
        vcv          = nan(numDep);
        kk           = 1;
        for tt =  start:T

            % Estimate 
            [betaFS(:,:,kk),stdBetaFS(:,:,kk),~,~,residual,zt] = nb_ols(Z(ss(kk):tt,eq),instT(ss(kk):tt,:),const,timeTrend,stdType);
            
            % Calculate predicted values and residual standard dev.
            zpred(ss(kk):tt,eq,kk) = zt*betaFS(:,:,kk);
            vcv(:,:,kk)            = residual'*residual/(size(residual,1) - numExoFS);
            
            kk = kk + 1;

        end
        
        % Store needed results
        firstStage(eq).beta    = betaFS;
        firstStage(eq).stdBeta = stdBetaFS;
        firstStage(eq).sigma   = vcv;
        
    end
    
    % Estimate the second stage
    beta    = nan(numCoeff,numDep,iter);
    stdBeta = nan(numCoeff,numDep,iter);
    vcv     = nan(numDep,numDep,iter);
    kk      = 1;
    for tt =  start:T
        
        % Estimate 
        [beta(:,:,kk),stdBeta(:,:,kk),~,~,residual,~] = nb_ols(y(ss(kk):tt,:),[X(ss(kk):tt,:),zpred(ss(kk):tt,:,kk)],const,timeTrend,stdType);
        vcv(:,:,kk)                                   = residual'*residual/(size(residual,1) - numCoeff);
        kk = kk + 1;
        
    end

    % Get estimation results
    %--------------------------------------------------
    res              = struct();
    res.beta         = beta;
    res.stdBeta      = stdBeta;
    res.sigma        = vcv;
    res.firstStage   = firstStage;

end

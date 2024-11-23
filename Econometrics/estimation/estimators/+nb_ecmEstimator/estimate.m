function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_ecmEstimator.estimate(options)
%
% Description:
%
% Estimate a ECM model with ols.
% 
% Input:
% 
% - options  : A struct on the format given by nb_ecmEstimator.template.
%              See also nb_ecmEstimator.help.
% 
% Output:
% 
% - result : A struct with the estimation results.
%
% - options : The return model options, can change when for example using
%             the 'modelSelection' otpions.
%
% See also:
% nb_ecmEstimator.print, nb_ecmEstimator.help, nb_ecmEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error('The options input cannot be empty!')
    end
    options = nb_defaultField(options,'removeZeroRegressors',false);
    options = nb_defaultField(options,'covidAdj',{});
    options = nb_defaultField(options,'nStep',0);
    options = nb_defaultField(options,'estim_types',{});

    % Get the estimation options
    %------------------------------------------------------
    if isfield(options,'bootstrap')
        % The else part is already done when called inside bootstrap 
        % routine
        startInd = options.estim_start_ind;
        endInd   = options.estim_end_ind;
    else
        
        tempDep  = cellstr(options.dependent);
        if isempty(tempDep)
            error(['No dependent variables selected, please assign the ',...
                'dependent field of the options property.'])
        end
        if numel(tempDep) ~= 1
            error('Only one dependent variable can be selected!')
        end
        [testY,indY] = ismember(tempDep,options.dataVariables);
        if any(~testY)
            error(['Some of the dependent variable are not found to ',...
                'be in the dataset; ' toString(tempDep(~testY))])
        end
        
        % These are the variables going into the cointegrated relation
        tempEndo = cellstr(options.endogenous); 
        if isempty(tempEndo)
            error(['Endogneous variables to be included in the ',...
                'cointegrated relation cannot be empty.'])
        end
        [testC,indC] = ismember(tempEndo,options.dataVariables);
        if any(~testC)
            error(['Some of the endogneous variable are not found to ',...
                'be in the dataset; ' toString(tempEndo(~testC))])
        end
        
        options.exogenous = cellstr(options.exogenous);
        [testX,indX]      = ismember(options.exogenous,options.dataVariables);
        if any(~testX)
            error(['Some of the exogenous variable are not found to be ',...
                'in the dataset; ' toString(options.exogenous(~testX))])
        end

        % Add lags to exogenous variables
        options = nb_estimator.addExoLags(options,'exoLags');

        % Shorten sample
        tempData        = options.data;
        y               = tempData(:,indY);
        X               = tempData(:,indX);
        C               = tempData(:,indC);
        [options,y,~,C] = nb_estimator.testSample(options,y,X,C);
        startInd        = options.estim_start_ind;
        endInd          = options.estim_end_ind;

        % Set up the equation(s) to estimate
        %------------------------------------------------------------------
        % Create the diff variables
        vars                  = [tempDep,tempEndo];
        nVars                 = length(vars);
        [~,indV]              = ismember(vars,options.dataVariables);
        V                     = tempData(:,indV);
        Vdiff                 = [nan(1,size(V,2));diff(V)];
        Vdifflag              = nb_mlag(Vdiff,1,'varFast');
        Vlag                  = nb_mlag(V,1,'varFast');
        tempData              = [tempData,Vdiff,Vdifflag,Vlag];
        options.dataVariables = [options.dataVariables,strcat('diff_',vars),...
            strcat('diff_',vars,'_lag1'),strcat(vars,'_lag1')];
        switch lower(options.method)

            case 'onestep'

                % diff_dep_t = c + g_1*dep_t_1 + g2*exo_t_1 + k*diff_exo_t + b_1*diff_dep_t_1 + e
                options.dependent = strcat('diff_',tempDep);
                options.rhs       = [strcat(vars,'_lag1'), strcat('diff_',tempEndo),strcat('diff_',tempDep,'_lag1')];
                fixed             = [true(1,length(vars)),false(1,length(vars))]; % Only the last lagged diff regressors are beeing choosen lag length
                startInd          = startInd + 2;
                nNotSort          = nVars;
                
            case 'twostep'

                if ~options.constant
                    error('Constant must be included in model in the two step method.')
                end
                if ~isempty(options.covidAdj)
                    error('The covidAdj option is not supported for the ''twostep'' method')
                end

                % Test for unit root in residual using an Engle-Granger test
                if isempty(options.criterion)
                    crit = 'aic';
                else
                    crit = options.criterion;
                end
                y              = nb_ts([y,C],'',options.dataStartDate,[tempDep,tempEndo],false);
                [egRes,models] = nb_egcoint(y,'dependent',tempDep{1},'lagLengthCrit',crit);

                % Get the residual from the first step
                residual              = models(1).results.residual;
                resLag                = nb_lag(residual);
                options.dataVariables = [options.dataVariables,'firstStepRes_lag1'];
                tempData              = [tempData,resLag];
                startInd              = startInd + 2;

                % diff_dep_t = c + g*firstStepResLag + k*diff_exo_t + b_1*diff_dep_t_1 + e
                options.dependent = strcat('diff_',tempDep);
                options.rhs       = [{'firstStepRes_lag1'}, strcat('diff_',tempEndo),...
                    strcat('diff_',tempDep,'_lag1')];

                % Only the last lagged diff regressors are beeing choosen lag length
                fixed    = [true(1,1),false(1,length(vars))]; 
                nNotSort = 1;
                
            otherwise
                error(['Unsupported method ' options.method])
        end

        % Get the estimation data
        %------------------------------------------------------
        % Add seasonal dummies
        options.data = tempData;
        if ~isempty(options.seasonalDummy)
            options = nb_olsEstimator.addSeasonalDummies(options);
        end

        % Add lags or find best model
        if ~isempty(options.modelSelection)

            options.modelSelectionFixed = [true(1,length(options.exogenous)),fixed];
            tempExo                     = cellstr(options.exogenous);
            options.exogenous           = [options.exogenous,options.rhs];
            options                     = nb_olsEstimator.modelSelectionAlgorithm(options);
            maxLags                     = max([options.nLags{:}]+1,[],2);
            options.rhs                 = options.exogenous(length(tempExo)+1:end);
            options.exogenous           = tempExo;

        else
            [options,maxLags] = nb_ecmEstimator.addECMlags(options,fixed);
        end
        startInd                = startInd + maxLags;
        options.estim_start_ind = startInd;
        
        % Sort the variables that may be selected lag length for
        options.rhs(nNotSort+1:end) = sort(options.rhs(nNotSort+1:end));
        
    end
    
    % Get data of the ECM model to estimate given lag length selection
    tempData    = options.data;
    [~,indY]    = ismember(options.dependent,options.dataVariables);
    y           = tempData(:,indY);
    [~,indX]    = ismember(options.exogenous,options.dataVariables);
    X           = tempData(:,indX);
    [~,indC]    = ismember(options.rhs,options.dataVariables);
    C           = tempData(:,indC);
    X           = [X,C];
    if isempty(y)
        error('The selected sample cannot be empty.')
    end
               
    % Do the estimation
    %------------------------------------------------------
    if size(X,2) == 0 && ~options.constant && ~options.time_trend
        error('You must select some regressors.')
    end

    % Check for constant regressors, which we do not allow
    if ~options.removeZeroRegressors
        if any(all(diff(X,1) == 0,1))
            error(['One or more of the selected exogenous variables is/are ',...
                'constant. Use the constant option instead.'])
        end
    end

    if options.recursive_estim
        
        if strcmpi(options.method,'twoStep')
            error('Recursive estimation with the two steps method is not yet supported.')
        end
        
        % Shorten sample
        %---------------
        y = y(startInd:endInd,:);
        X = X(startInd:endInd,:); 

        % Ignore some covid dates?
        indCovid = nb_estimator.applyCovidFilter(options,y);
        
        % Check the sample
        numCoeff                = size(X,2) + options.constant + options.time_trend;
        T                       = size(y,1);
        [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,numCoeff,T);

        % Estimate the model recursively
        %--------------------------------------------------
        numDep     = size(y,2);
        beta       = zeros(numCoeff,numDep,iter);
        stdBeta    = nan(numCoeff,numDep,iter);
        constant   = options.constant;
        time_trend = options.time_trend;
        stdType    = options.stdType;
        residual   = nan(T,numDep,iter);
        kk         = 1;
        for tt = start:T
            
            if options.removeZeroRegressors
                ind  = ~all(abs(X(ss(kk):tt,:)) < eps,1);
                indA = [true(1,numCoeff - size(X,2)), ind];
            else
                ind  = true(1,size(X,2));
                indA = true(1,numCoeff);
            end

            yEst = y(ss(kk):tt,:);
            XEst = X(ss(kk):tt,ind);
            if ~isempty(indCovid)
                % Strip covid dates from estimation
                yEstCov = yEst(~indCovid(ss(kk):tt,:),:);
                XEstCov = XEst(~indCovid(ss(kk):tt,:),:);
                yEst    = yEst(indCovid(ss(kk):tt,:),:);
                XEst    = XEst(indCovid(ss(kk):tt,:),:);
            end
            
            [beta(indA,:,kk),stdBeta(indA,:,kk),~,~,resid] = ...
                nb_ols(yEst,XEst,constant,time_trend,stdType);

            if ~isempty(indCovid)
                resid = nb_estimator.predictResidual(yEstCov,XEstCov,...
                    constant,time_trend,beta(indA,:,kk),resid,...
                    indCovid(ss(kk):tt,:));
            end
            residual(ss(kk):tt,:,kk) = resid;

            kk = kk + 1;  
        end
        
        % Estimate the covariance matrix
        %--------------------------------
        vcv = nb_estimator.estimateCovarianceMatrixDuringRecEst(...
                options,residual,indCovid,start,T,ss,numCoeff);

        % Get estimation results
        %--------------------------------------------------
        results          = struct();
        results.beta     = beta;
        results.stdBeta  = stdBeta;
        results.sigma    = vcv;
        results.residual = residual;

    %======================
    else % Not recursive
    %======================
        
        % Get estimation sample
        %--------------------------------------------------
        % Shorten sample
        y = y(startInd:endInd,:);
        X = X(startInd:endInd,:); 

        % Ignore some covid dates?
        indCovid = nb_estimator.applyCovidFilter(options,y);

        % Check the degrees of freedom
        numCoeff = size(X,2) + options.constant + options.time_trend;
        T        = size(X,1);
        nb_estimator.checkDOF(options,numCoeff,T);
        
        % Estimate model by ols
        %--------------------------------------------------
        if options.removeZeroRegressors
            ind  = ~all(abs(X) < eps);
        else
            ind  = true(1,size(X,2));
        end

        yEst = y;
        XEst = X(:,ind);
        if ~isempty(indCovid)
            yEstCov = yEst(~indCovid,:);
            XEstCov = XEst(~indCovid,:);
            yEst    = yEst(indCovid,:);
            XEst    = XEst(indCovid,:);
        end
        
        [beta,stdBeta,tStatBeta,pValBeta,residual,XX] = nb_ols(yEst,XEst,...
            options.constant,options.time_trend,options.stdType);
        
        residualStripped = residual;
        if ~isempty(indCovid)
            residual = nb_estimator.predictResidual(yEstCov,XEstCov,...
                options.constant,options.time_trend,beta,residual,...
                indCovid);
        end

        % Estimate the covariance matrix
        %-------------------------------
        T     = size(residualStripped,1);
        sigma = residualStripped'*residualStripped/(T - numCoeff);
        
        % Get estimation results
        %--------------------------------------------------
        results = struct();
        if options.removeZeroRegressors
            numEq                     = size(y,2);
            indA                      = [true(1,numCoeff - size(X,2)), ind];
            results.beta              = zeros(numCoeff,numEq);
            results.beta(indA,:)      = beta;
            results.stdBeta           = nan(numCoeff,numEq);
            results.stdBeta(indA,:)   = stdBeta; 
            results.tStatBeta         = nan(numCoeff,numEq);
            results.tStatBeta(indA,:) = tStatBeta;
            results.pValBeta          = nan(numCoeff,numEq);
            results.pValBeta(indA,:)  = pValBeta;
        else
            results.beta       = beta;
            results.stdBeta    = stdBeta;
            results.tStatBeta  = tStatBeta;
            results.pValBeta   = pValBeta;
        end
        results.residual   = residual;
        results.sigma      = sigma;
        results.predicted  = y - residual;
        results.regressors = XX;
        
        % Get aditional test results
        %--------------------------------------------------
        if options.doTests
            if isempty(indCovid)
                yTest = y;
                XTest = X;
            else
                yTest = y(indCovid,:);
                XTest = X(indCovid,:);
            end
            results = nb_olsEstimator.doTest(results,options,results.beta,...
                yTest,XTest,residualStripped);
        end
        
        if strcmpi(options.method,'twostep')
            results.egResults  = egRes;
            results.firstStep  = models;
        end
        
    end

    % Assign generic results
    results.includedObservations = size(y,1);
    results.elapsedTime          = toc(tStart);
    
    % Assign results
    options.estim_start_ind = startInd;
    options.estim_end_ind   = endInd;
    options.estimator       = 'nb_ecmEstimator';
    options.estimType       = 'classic';

end

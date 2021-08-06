function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_olsEstimator.estimate(options)
%
% Description:
%
% Estimate a model with ols.
% 
% Input:
% 
% - options  : A struct on the format given by nb_olsEstimator.template.
%              See also nb_olsEstimator.help.
% 
% Output:
% 
% - result : A struct with the estimation results.
%
% - options : The return model options, can change when for example using
%             the 'modelSelection' otpions.
%
% See also:
% nb_olsEstimator.print, nb_olsEstimator.help, nb_olsEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end
    options = nb_defaultField(options,'class','');
    options = nb_defaultField(options,'requiredDegreeOfFreedom',3);
    options = nb_defaultField(options,'modelSelection','');
    options = nb_defaultField(options,'modelSelectionFixed',[]);
    options = nb_defaultField(options,'seasonalDummy','');
    options = nb_defaultField(options,'addLags',true);
    options = nb_defaultField(options,'restrictions',{});
    options = nb_defaultField(options,'unbalanced',false);
    options = nb_defaultField(options,'removeZeroRegressors',false);
    
    if ~ismember(options.stdType,{'h','w','nw'})
        options.stdType = 'h';
    end
    
    % Are we dealing with a VAR?
    %-------------------------------------------------------
    if isfield(options,'class')
        if strcmpi(options.class,'nb_var')
            options = nb_olsEstimator.varModifications(options); 
        end
    end
    
    % Get the estimation options
    %------------------------------------------------------
    tempDep  = cellstr(options.dependent);
    if isempty(tempDep)
        error([mfilename ':: No dependent variables selected, please assign the dependent field of the options property.'])
    end
    options.exogenous = cellstr(options.exogenous);
    
    if isempty(options.data)
        error([mfilename ':: Cannot estimate without data.'])
    end

    if isempty(options.modelSelectionFixed)
        fixed = false(1,length(options.exogenous));
    else
        fixed = options.modelSelectionFixed;
        if ~islogical(fixed)
            fixed = logical(options.modelSelectionFixed);
        end
    end
    options.modelSelectionFixed = fixed;

    % Get the estimation data
    %------------------------------------------------------
    if isempty(options.estim_types) % Time-series

        % Add seasonal dummies
        if ~isempty(options.seasonalDummy)
            options = nb_olsEstimator.addSeasonalDummies(options); 
        end
        
        % Do we deal with unbalanced dataset?
        if options.unbalanced
            options = nb_estimator.correctOptionsForUnbalanced(options);
        elseif strcmpi(options.class,'nb_sa')
            if ~isempty(options.estim_end_ind)
                options.estim_end_ind = options.estim_end_ind - options.nStep;
            end
            if ~isempty(options.recursive_estim_start_ind)
                options.recursive_estim_start_ind = options.recursive_estim_start_ind - options.nStep;
            end
        end
        
        % Add lags or find best model
        if ~isempty(options.modelSelection)

            if options.unbalanced
                error([mfilename ':: The unbalanced option cannot be set to true at the same time as using model selection.'])
            end
            if ~isempty(options.restrictions)
                error([mfilename ':: Parameter restrictions cannot be applied at the same time as using model selection.'])
            end
            minLags = [];
            if isfield(options,'class')
                if strcmpi(options.class,'nb_var')
                    minLags = 0; 
                end
            end
            options = nb_olsEstimator.modelSelectionAlgorithm(options,minLags); 
            
        else
            if options.addLags
                if iscell(options.nLags)
                    if isfield(options,'class')
                        if strcmpi(options.class,'nb_var')
                            error([mfilename ':: The ''nLags'' cannot be a cell, if the model is of class nb_var.'])
                        end
                    end
                    options = nb_estimator.addExoLags(options,'nLags');  
                elseif ~all(options.nLags == 0) 
                    options = nb_olsEstimator.addLags(options);
                end
            end
            if options.unbalanced
                options = nb_olsEstimator.addLeads(options);
            end
        end
        
        % Check if we need have a block_exogenous model
        %----------------------------------------------
        blockRest = {};
        if isfield(options,'block_exogenous')
            if ~isempty(options.block_exogenous)
                tempDep   = [tempDep,options.block_exogenous];
                blockRest = nb_estimator.getBlockExogenousRestrictions(options);
            end
        end
        
        % Get data
        [testY,indY] = ismember(tempDep,options.dataVariables);
        [testX,indX] = ismember(options.exogenous,options.dataVariables);
        if any(~testY)
            error([mfilename ':: Some of the dependent variable are not found to be in the dataset; ' toString(tempDep(~testY))])
        end
        if any(~testX)
            error([mfilename ':: Some of the exogenous variable are not found to be in the dataset; ' toString(options.exogenous(~testX))])
        end
        y = options.data(:,indY);
        X = options.data(:,indX);
        if isempty(y)
            error([mfilename ':: The selected sample cannot be empty.'])
        end
        
    else

        % Get data as a double
        [testY,indY] = ismember(tempDep,options.dataVariables);
        [testT,indT] = ismember(options.estim_types,options.dataTypes);
        [testX,indX] = ismember(options.exogenous,options.dataVariables);
        if any(~testY)
            error([mfilename ':: Some of the dependent variables are not found to be in the dataset; ' toString(tempDep(~testY))])
        end
        if any(~testX)
            error([mfilename ':: Some of the exogenous variables are not found to be in the dataset; ' toString(options.exogenous(~testX))])
        end
        if any(~testT)
            error([mfilename ':: Some of the types are not found to be in the dataset; ' toString(options.estim_types(~testT))])
        end
        y = options.data(indT,indY);
        X = options.data(indT,indX);
        if isempty(y)
            error([mfilename ':: The number of selected types cannot be 0.'])
        end

    end
    
    % Apply restrictions
    if ~isempty(options.restrictions)
        [yRest,XRest,restrict] = nb_estimator.applyRestrictions(options,y,X);
    else
        yRest = y;
        XRest = X;
    end
    
    % Do the estimation
    %------------------------------------------------------
%     if size(X,2) == 0 && ~options.constant && ~options.time_trend
%         error([mfilename ':: You must select some regressors.'])
%     end

    % Check for constant regressors, which we do not allow
    if ~options.removeZeroRegressors
        if any(all(diff(X,1) == 0,1))
            error([mfilename ':: One or more of the selected exogenous variables is/are constant. '...
                             'Use the constant option instead.'])
        end
    end

    if options.recursive_estim

        if ~isempty(options.estim_types)
            error([mfilename ':: Recursive estimation is only supported for time-series.'])
        end
        
        % Shorten sample
        [options,yRest,XRest] = nb_estimator.testSample(options,yRest,XRest);

        % Check the sample
        numCoeff                = size(XRest,2) + options.constant + options.time_trend;
        T                       = size(yRest,1);
        [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,numCoeff,T);
            
        if numCoeff == 0
            
            % All parameters are restricted
            numDep   = size(yRest,2);
            beta     = nan(numCoeff,numDep,iter);
            stdBeta  = nan(numCoeff,numDep,iter);
            residual = nan(T,numDep,iter);
            vcv      = nan(numDep,numDep,iter);
            
            % Estimate the covariance matrix
            kk = 1;
            for tt = start:T
                residual(ss(kk):tt,:,kk) = yRest(ss(kk):tt,:);
                kk                       = kk + 1;
            end
            
            kk = 1;
            for tt = start:T
                resid       = residual(ss(kk):tt,:,kk);
                vcv(:,:,kk) = resid'*resid/(size(resid,1) - numCoeff);
                kk          = kk + 1;
            end
            
        else
            
            % Estimate the model recursively
            %--------------------------------------------------
            numDep     = size(yRest,2);
            beta       = zeros(numCoeff,numDep,iter);
            stdBeta    = nan(numCoeff,numDep,iter);
            constant   = options.constant;
            time_trend = options.time_trend;
            stdType    = options.stdType;
            residual   = nan(T,numDep,iter);
            kk         = 1;
            vcv        = nan(numDep,numDep,iter);
            if isempty(blockRest)
                for tt = start:T
                    
                    if options.removeZeroRegressors
                        ind  = ~all(abs(XRest(ss(kk):tt,:)) < eps,1);
                        indA = [true(1,numCoeff - size(XRest,2)), ind];
                    else
                        ind  = true(1,size(XRest,2));
                        indA = true(1,numCoeff);
                    end
                    
                    [beta(indA,:,kk),stdBeta(indA,:,kk),~,~,residual(ss(kk):tt,:,kk)] = nb_ols(yRest(ss(kk):tt,:),XRest(ss(kk):tt,ind),constant,time_trend,stdType);
                    kk = kk + 1;
                end
            else
                for tt = start:T
                    
                    if options.removeZeroRegressors
                        ind  = ~all(abs(XRest(ss(kk):tt,:)) < eps,1);
                        indA = [true(1,numCoeff - size(XRest,2)), ind];
                    else
                        ind  = true(1,size(XRest,2));
                        indA = true(1,numCoeff);
                    end
                    blockRestIndexed                                                  = indexBlockRest(options,blockRest,ind);
                    [beta(indA,:,kk),stdBeta(indA,:,kk),~,~,residual(ss(kk):tt,:,kk)] = nb_olsRestricted(yRest(ss(kk):tt,:),XRest(ss(kk):tt,ind),blockRestIndexed,constant,time_trend,stdType);
                    kk = kk + 1;
                end
            end
            
            % Estimate the covariance matrix
            %--------------------------------
            kk = 1;
            for tt = start:T
                resid       = residual(ss(kk):tt,:,kk);
                vcv(:,:,kk) = resid'*resid/(size(resid,1) - numCoeff);
                kk          = kk + 1;
            end
            
        end
        
        % Get estimation results
        %--------------------------------------------------
        res          = struct();
        res.beta     = beta;
        res.stdBeta  = stdBeta;
        res.sigma    = vcv;
        res.residual = residual;
        
        % Add restrictions to results
        if ~isempty(options.restrictions)
            res = nb_estimator.addRestrictions(options,res,restrict);
        end

    %======================
    else % Not recursive
    %======================
        
        % Get estimation sample
        %--------------------------------------------------
        if isempty(options.estim_types) 
            
            % Shorten sample
            [options,y,yRest,XRest] = nb_estimator.testSample(options,y,yRest,XRest);

            % Check the degrees of freedom
            numCoeff = size(XRest,2) + options.constant + options.time_trend;
            T        = size(XRest,1);
            nb_estimator.checkDOF(options,numCoeff,T);

        else
            
            numCoeff = size(XRest,2) + options.constant;
            N        = size(XRest,1);
            nb_estimator.checkDOF(options,numCoeff,N);
            
            % Secure that the data is balanced
            %------------------------------------------------------
            testData = [yRest,XRest];
            testData = testData(:);
            if any(isnan(testData))
                error([mfilename ':: The estimation data is not balanced.'])
            end
            
        end
        
        % Estimate model by ols
        %--------------------------------------------------
        if numCoeff == 0
            % All parameters are restricted
            numDep    = size(yRest,2);
            beta      = nan(numCoeff,numDep);
            stdBeta   = nan(numCoeff,numDep);
            tStatBeta = nan(numCoeff,numDep);
            pValBeta  = nan(numCoeff,numDep);
            residual  = yRest;
            XX        = [];
        else
            
            if options.removeZeroRegressors
                ind  = ~all(abs(XRest) < eps);
            else
                ind  = true(1,size(XRest,2));
            end
            
            if isempty(blockRest)
                [beta,stdBeta,tStatBeta,pValBeta,residual,XX] = nb_ols(yRest,XRest(:,ind),options.constant,options.time_trend,options.stdType);
            else
                blockRestIndexed                              = indexBlockRest(options,blockRest,ind);
                [beta,stdBeta,tStatBeta,pValBeta,residual,XX] = nb_olsRestricted(yRest,XRest(:,ind),blockRestIndexed,options.constant,options.time_trend,options.stdType);
            end
            
        end
        
        % Estimate the covariance matrix
        %-------------------------------
        T     = size(residual,1);
        sigma = residual'*residual/(T - numCoeff);
        
        % Get estimation results
        %--------------------------------------------------
        res = struct();
        if options.removeZeroRegressors
            numEq                 = size(y,2);
            indA                  = [true(1,numCoeff - size(XRest,2)), ind];
            res.beta              = zeros(numCoeff,numEq);
            res.beta(indA,:)      = beta;
            res.stdBeta           = nan(numCoeff,numEq);
            res.stdBeta(indA,:)   = stdBeta; 
            res.tStatBeta         = nan(numCoeff,numEq);
            res.tStatBeta(indA,:) = tStatBeta;
            res.pValBeta          = nan(numCoeff,numEq);
            res.pValBeta(indA,:)  = pValBeta;
        else
            res.beta       = beta;
            res.stdBeta    = stdBeta;
            res.tStatBeta  = tStatBeta;
            res.pValBeta   = pValBeta;
        end
        res.residual   = residual;
        res.sigma      = sigma;
        res.predicted  = y - residual;
        res.regressors = XX;
        
        % Add restrictions to results
        if ~isempty(options.restrictions)
            res = nb_estimator.addRestrictions(options,res,restrict);
        end
        
        % Get aditional test results
        %--------------------------------------------------
        if options.doTests
            res = nb_olsEstimator.doTest(res,options,res.beta,y,X,residual);
        end
        
    end
    
    % Correct estimation dates for nb_sa models
    if strcmpi(options.class,'nb_sa')
        options.estim_end_ind             = options.estim_end_ind + options.nStep;
        options.recursive_estim_start_ind = options.recursive_estim_start_ind + options.nStep;
    end
    
    if options.unbalanced 
        [res,options] = nb_estimator.correctResultsGivenUnbalanced(options,res);
    end
    
    % Secure that all lags of the solution is in the data!
    if isempty(options.estim_types) && strcmpi(options.class,'nb_singleEq') % Time-series
        options = nb_olsEstimator.secureAllLags(options);
    end
    
    % Assign generic results
    res.includedObservations = size(yRest,1);
    res.elapsedTime          = toc(tStart);
    
    % Assign results
    results = res;
    options.estimator = 'nb_olsEstimator';
    options.estimType = 'classic';

end

%==========================================================================
function blockRestIndexed = indexBlockRest(options,blockRest,ind)

    if options.removeZeroRegressors
        indB = ind;
        if options.time_trend
            indB = [true,indB];
        end
        if options.constant
            indB = [true,indB];
        end
        blockRestIndexed = blockRest;
        for ii = 1:length(blockRest)
            blockRestIndexed{ii} = blockRest{ii}(indB);
        end
    else
        blockRestIndexed = blockRest;
    end

end


function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_quantileEstimator.estimate(options)
%
% Description:
%
% Estimate a model with quantile regression.
% 
% Input:
% 
% - options  : A struct on the format given by 
%              nb_quantileEstimator.template. See also 
%              nb_quantileEstimator.help.
% 
% Output:
% 
% - result  : A struct with the estimation results.
%
% - options : The return model options, can change when for example using
%             the 'modelSelection' otpions.
%
% See also:
% nb_quantileEstimator.print, nb_quantileEstimator.help, 
% nb_quantileEstimator.template
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
    options = nb_defaultField(options,'nStep',0);
    options = nb_defaultField(options,'seasonalDummy','');
    options = nb_defaultField(options,'addLags',true);
    options = nb_defaultField(options,'unbalanced',false);
    options = nb_defaultField(options,'removeZeroRegressors',false);
    if any(strcmpi(options.stdType,{'h','nw','w'}))
        options.stdType = 'sparsity';
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
    tempData = options.data;
    if isempty(tempDep)
        error([mfilename ':: No dependent variables selected, please assign the dependent field of the options property.'])
    end
    tempExo = cellstr(options.exogenous);
    
    if isempty(tempData)
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
        restrictions = {};
        if isfield(options,'block_exogenous')
            if ~isempty(options.block_exogenous)
                tempDep      = [tempDep,options.block_exogenous];
                restrictions = nb_estimator.getBlockExogenousRestrictions(options);
            end
        end
        
        % Get data
        tempData     = options.data;
        [testY,indY] = ismember(tempDep,options.dataVariables);
        [testX,indX] = ismember(options.exogenous,options.dataVariables);
        if any(~testY)
            error([mfilename ':: Some of the dependent variable are not found to be in the dataset; ' toString(tempDep(~testY))])
        end
        if any(~testX)
            error([mfilename ':: Some of the exogenous variable are not found to be in the dataset; ' toString(options.exogenous(~testX))])
        end
        y = tempData(:,indY);
        X = tempData(:,indX);
        if isempty(y)
            error([mfilename ':: The selected sample cannot be empty.'])
        end
        
    else

        % Get data as a double
        [testY,indY] = ismember(tempDep,options.dataVariables);
        [testT,indT] = ismember(options.estim_types,options.dataTypes);
        [testX,indX] = ismember(tempExo,options.dataVariables);
        if any(~testY)
            error([mfilename ':: Some of the dependent variable are not found to be in the dataset; ' toString(tempDep(~testY))])
        end
        if any(~testX)
            error([mfilename ':: Some of the exogenous variable are not found to be in the dataset; ' toString(options.exogenous(~testX))])
        end
        if any(~testT)
            error([mfilename ':: Some of the types are not found to be in the dataset; ' toString(options.estim_types(~testT))])
        end
        y = tempData(indT,indY);
        X = tempData(indT,indX);
        if isempty(y)
            error([mfilename ':: The number of selected types cannot be 0.'])
        end

    end
    
    % Do the estimation
    %------------------------------------------------------
    if size(X,2) == 0 && ~options.constant && ~options.time_trend
        error([mfilename ':: You must select some regressors.'])
    end

    % Check for constant regressors, which we do not allow
    if ~options.removeZeroRegressors
        if any(all(diff(X,1) == 0,1))
            error([mfilename ':: One or more of the selected exogenous variables is/are constant. '...
                             'Use the constant option instead.'])
        end
    end

    q = options.quantile;
    if options.recursive_estim

        if ~isempty(options.estim_types)
            error([mfilename ':: Recursive estimation is only supported for time-series.'])
        end
        
        % Shorten sample
        [options,y,X] = nb_estimator.testSample(options,y,X);

        % Check the sample
        numCoeff                = size(X,2) + options.constant + options.time_trend;
        T                       = size(y,1);
        [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,numCoeff,T);
            
        % Create waiting bar window
        waitbar = false;
        if options.waitbar
            [h,doDelete] = nb_estimator.openWaitbar(options,iter);
            if ~isempty(h)
                h.lock  = 2;
                note    = nb_when2Notify(iter);
                waitbar = true;
            end
        else
            h = false;
        end
        
        % Estimate the model recursively
        %--------------------------------------------------
        numDep     = size(y,2);
        beta       = nan(numCoeff,numDep,length(q),iter);
        stdBeta    = nan(numCoeff,numDep,length(q),iter);
        constant   = options.constant;
        time_trend = options.time_trend;
        stdType    = options.stdType;
        residual   = nan(T,numDep,length(q),iter);
        kk         = 1;
        vcv        = nan(numDep,numDep,iter,length(q));
        for tt = start:T
            
            if options.removeZeroRegressors
                ind  = ~all(abs(X(ss(kk):tt,:)) < eps,1);
                indA = [true(1,numCoeff - size(X,2)), ind];
            else
                ind  = true(1,size(X,2));
                indA = true(1,numCoeff);
            end
            
            [beta(indA,:,:,kk),stdBeta(indA,:,:,kk),~,~,residual(ss(kk):tt,:,:,kk)] = nb_qreg(q,y(ss(kk):tt,:),X(ss(kk):tt,ind),constant,time_trend,stdType,1000,restrictions,options.waitbar);
            if waitbar 
                nb_estimator.notifyWaitbar(h,kk,iter,note)
            end
            kk = kk + 1; 
            
        end
        
        % Estimate the covariance matrix
        %--------------------------------
        residual = permute(residual,[1,2,4,3]);
        for qq = 1:length(q)
            kk = 1;
            for tt = start:T
                resid          = residual(ss(kk):tt,:,kk,qq);
                residClean     = bsxfun(@minus,resid,mean(resid,1));
                vcv(:,:,kk,qq) = residClean'*residClean/(size(resid,1) - numCoeff);
                kk             = kk + 1;
            end
        end

        % Get estimation results
        %--------------------------------------------------
        res          = struct();
        res.beta     = permute(beta,[1,2,4,3]);
        res.stdBeta  = permute(stdBeta,[1,2,4,3]);
        res.sigma    = vcv;
        res.residual = residual;
        
        if waitbar && doDelete
            delete(h);
        end

    %======================
    else % Not recursive
    %======================
        
        % Get estimation sample
        %--------------------------------------------------
        if isempty(options.estim_types) 

            % Shorten sample
            [options,y,X] = nb_estimator.testSample(options,y,X);
            
            % Check the degrees of freedom
            numCoeff = size(X,2) + options.constant + options.time_trend;
            T        = size(X,1);
            nb_estimator.checkDOF(options,numCoeff,T);

        else
            
            numCoeff = size(X,2) + options.constant;
            N        = size(X,1);
            nb_estimator.checkDOF(options,numCoeff,N);
            
            % Secure that the data is balanced
            %------------------------------------------------------
            testData = [y,X];
            testData = testData(:);
            if any(isnan(testData))
                error([mfilename ':: The estimation data is not balanced.'])
            end
            
        end
        
        % Estimate model by quantile regression
        %--------------------------------------------------
        if options.removeZeroRegressors
            ind  = ~all(abs(X) < eps);
        else
            ind  = true(1,size(X,2));
        end
        
        [beta,stdBeta,tStatBeta,pValBeta,residual,XX] = nb_qreg(q,y,X(:,ind),options.constant,options.time_trend,options.stdType,1000,restrictions,options.waitbar);
        
        % Estimate the covariance matrix
        %-------------------------------
        T     = size(residual,1);
        E     = size(beta,2);
        sigma = nan(E,E,1,length(q)); 
        for qq = 1:length(q)
            resid           = residual(:,:,qq);
            residClean      = bsxfun(@minus,resid,mean(resid,1));
            sigma(:,:,:,qq) = residClean'*residClean/(T - numCoeff);
        end
        
        % Get estimation results (parameters for each quantile is added 
        % in the 4th dimension)
        %------------------------------------------------------------------
        res = struct();
        if options.removeZeroRegressors
            numEq                     = size(y,2);
            indA                      = [true(1,numCoeff - size(XRest,2)), ind];
            res.beta                  = zeros(numCoeff,numEq,1,length(q));
            res.beta(indA,:,:,:)      = permute(beta,[1,2,4,3]);
            res.stdBeta               = nan(numCoeff,numEq,1,length(q));
            res.stdBeta(indA,:,:,:)   = permute(stdBeta,[1,2,4,3]); 
            res.tStatBeta             = nan(numCoeff,numEq,1,length(q));
            res.tStatBeta(indA,:,:,:) = permute(tStatBeta,[1,2,4,3]);
            res.pValBeta              = nan(numCoeff,numEq,1,length(q));
            res.pValBeta(indA,:,:,:)  = permute(pValBeta,[1,2,4,3]);
        else
            res.beta       = permute(beta,[1,2,4,3]);
            res.stdBeta    = permute(stdBeta,[1,2,4,3]);
            res.tStatBeta  = permute(tStatBeta,[1,2,4,3]);
            res.pValBeta   = permute(pValBeta,[1,2,4,3]);
        end
        
        res.residual   = permute(residual,[1,2,4,3]);
        res.sigma      = sigma;
        res.predicted  = bsxfun(@minus,y,res.residual);
        res.regressors = XX;
        
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
    res.includedObservations = size(y,1);
    res.elapsedTime          = toc(tStart);
    
    % Assign results
    results = res;
    options.estimator = 'nb_quantileEstimator';
    options.estimType = 'classic';

end


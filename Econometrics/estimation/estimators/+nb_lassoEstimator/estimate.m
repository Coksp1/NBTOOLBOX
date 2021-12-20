function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_lassoEstimator.estimate(options)
%
% Description:
%
% Estimate a model with LASSO.
% 
% Input:
% 
% - options  : A struct on the format given by nb_lassoEstimator.template.
%              See also nb_lassoEstimator.help.
% 
% Output:
% 
% - result : A struct with the estimation results.
%
% - options : The return model options, can change when for example using
%             the 'modelSelection' otpions.
%
% See also:
% nb_lassoEstimator.print, nb_lassoEstimator.help, 
% nb_lassoEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end
    options = nb_defaultField(options,'class','');
    options = nb_defaultField(options,'requiredDegreeOfFreedom',3);
    options = nb_defaultField(options,'seasonalDummy','');
    options = nb_defaultField(options,'restrictions',{});
    options = nb_defaultField(options,'unbalanced',false);
    options = nb_defaultField(options,'removeZeroRegressors',false);
    options = nb_defaultField(options,'time_trend',false);
    options = nb_defaultField(options,'modelSelection',false);
    
    if options.time_trend
        error('The time_trend options is not supported for LASSO estimation. Set it to false.')
    end
    if ~isempty(options.modelSelection)
        error('The modelSelection options is not supported for LASSO estimation. Set it to ''''.')
    end
    
    % Get the estimation options
    %------------------------------------------------------
    tempDep = cellstr(options.dependent);
    if isempty(tempDep)
        error([mfilename ':: No dependent variables selected, please assign the dependent field of the options property.'])
    end
    options.exogenous = cellstr(options.exogenous);
    
    if isempty(options.data)
        error([mfilename ':: Cannot estimate without data.'])
    end

    % Get the estimation data
    %------------------------------------------------------
    if isempty(options.estim_types) % Time-series

        % Add seasonal dummies
        if ~isempty(options.seasonalDummy)
            options = nb_olsEstimator.addSeasonalDummies(options); 
        end
        
        % Add lags
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
    
    % Do the estimation
    %------------------------------------------------------

    % Check for constant regressors, which we do not allow
    if any(all(diff(X,1) == 0,1))
        error([mfilename ':: One or more of the selected exogenous variables is/are constant. '...
                         'Use the constant option instead.'])
    end

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
            
        % Estimate the model recursively
        %--------------------------------------------------
        numDep   = size(y,2);
        beta     = zeros(numCoeff,numDep,iter);
        stdBeta  = nan(numCoeff,numDep,iter);
        constant = options.constant;
        residual = nan(T,numDep,iter);
        kk       = 1;
        vcv      = nan(numDep,numDep,iter);
        if isempty(options.optimset.beta0)
            options.optimset.beta0 = zeros(numCoeff - constant,1);
        end
        for tt = start:T

            % Remove zero regressors
            if options.removeZeroRegressors
                ind  = ~all(abs(X(ss(kk):tt,:)) < eps,1);
                indA = [true(1,numCoeff - size(X,2)), ind];
            else
                ind  = true(1,size(X,2));
                indA = true(1,numCoeff);
            end
            options.optimset.beta0 = options.optimset.beta0(ind);
            
            % Do estimation
            [beta(indA,:,kk),exitflag,residual(ss(kk):tt,:,kk)] = nb_lasso(y(ss(kk):tt,:),X(ss(kk):tt,ind),options.regularization,constant,options.optimset);
            if exitflag < 0
                nb_interpretExitFlag(exitflag,'nb_lasso',[' Failed during LASSO estimation for iteration ' int2str(tt)])
            end
            
            % Set starting values for next iteration
            options.optimset.beta0 = beta(:,:,kk);
            kk = kk + 1;
            
        end

        % Estimate the covariance matrix
        %--------------------------------
        kk = 1;
        for tt = start:T
            resid       = residual(ss(kk):tt,:,kk);
            vcv(:,:,kk) = resid'*resid/(size(resid,1) - numCoeff);
            kk          = kk + 1;
        end
        
        % Get estimation results
        %--------------------------------------------------
        res          = struct();
        res.beta     = beta;
        res.stdBeta  = stdBeta;
        res.sigma    = vcv;
        res.residual = residual;
        
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
        
        % Estimate model by ols
        %-------------------------------------------------- 
        if options.removeZeroRegressors
            ind  = ~all(abs(X) < eps);
        else
            ind  = true(1,size(X,2));
        end

        [beta,exitflag,residual,XX] = nb_lasso(y,X(:,ind),options.regularization,options.constant,options.optimset);
        if exitflag < 0
            nb_interpretExitFlag(exitflag,'nb_lasso',' Failed during LASSO estimation')
        end
        stdBeta = nan(size(beta));
        
        % Estimate the covariance matrix
        %-------------------------------
        T     = size(residual,1);
        sigma = residual'*residual/(T - numCoeff);
        
        % Get estimation results
        %--------------------------------------------------
        res = struct();
        if options.removeZeroRegressors
            numEq                 = size(y,2);
            indA                  = [true(1,numCoeff - size(X,2)), ind];
            res.beta              = zeros(numCoeff,numEq);
            res.beta(indA,:)      = beta;
            res.stdBeta           = nan(numCoeff,numEq);
            res.stdBeta(indA,:)   = stdBeta; 
        else
            res.beta    = beta;
            res.stdBeta = stdBeta;
        end
        res.residual   = residual;
        res.sigma      = sigma;
        res.predicted  = y - residual;
        res.regressors = XX;
        
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
    options.estimator = 'nb_lassoEstimator';
    options.estimType = 'classic';

end

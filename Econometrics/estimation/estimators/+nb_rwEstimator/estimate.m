function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_rwEstimator.estimate(options)
%
% Description:
%
% Estimate a random walk model.
% 
% Input:
% 
% - options : A struct on the format given by nb_rwEstimator.template.
%             See also nb_rwEstimator.help.
% 
% Output:
% 
% - result  : A struct with the estimation results.
%
% - options : The return model options.
%
% See also:
% nb_rwEstimator.print, nb_rwEstimator.help, nb_rwEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end
    options = nb_defaultField(options,'class','');
    options = nb_defaultField(options,'requiredDegreeOfFreedom',3);
    options = nb_defaultField(options,'seasonalDummy','');
    options = nb_defaultField(options,'removeZeroRegressors',false);
    options = nb_defaultField(options,'time_trend',false);
    if ~ismember(options.stdType,{'h','w','nw'})
        options.stdType = 'h';
    end
    
    % Get the estimation options
    %------------------------------------------------------
    options.dependent = cellstr(options.dependent);
    if isempty(options.dependent)
        error([mfilename ':: No dependent variables selected, please assign the dependent field of the options property.'])
    end
    if length(options.dependent) > 1
        error([mfilename ':: Only one dependent variable can be selected for the random walk estimator.'])
    end
    options.exogenous = cellstr(options.exogenous);
    
    if isempty(options.data)
        error([mfilename ':: Cannot estimate without data.'])
    end

    % Get the estimation data
    %------------------------------------------------------
    
    % Add seasonal dummies
    if ~isempty(options.seasonalDummy)
        options = nb_olsEstimator.addSeasonalDummies(options); 
    end

    % Get data
    [testY,indY] = ismember(options.dependent,options.dataVariables);
    [testX,indX] = ismember(options.exogenous,options.dataVariables);
    if any(~testY)
        error([mfilename ':: Some of the dependent variable are not found to be in the dataset; ' toString(options.dependent(~testY))])
    end
    if any(~testX)
        error([mfilename ':: Some of the exogenous variable are not found to be in the dataset; ' toString(options.exogenous(~testX))])
    end
    y = options.data(:,indY);
    if isempty(y)
        error([mfilename ':: The selected sample cannot be empty.'])
    end
    y = y - nb_lag(y,1);
    X = options.data(:,indX);
    
    % Do the estimation
    %------------------------------------------------------
    % Check for constant regressors, which we do not allow
    if ~options.removeZeroRegressors
        if any(all(diff(X,1) == 0,1))
            error([mfilename ':: One or more of the selected exogenous variables is/are constant. '...
                             'Use the constant option instead.'])
        end
    end

    constant = options.constant;
    numDep   = size(y,2);
    if options.recursive_estim

        % Shorten sample
        [options,y,X] = nb_estimator.testSample(options,y,X);

        % Check the sample
        numCoeff                = size(X,2) + options.constant;
        T                       = size(y,1);
        [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,numCoeff,T);
            
        if numCoeff == 0
            
            % All parameters are restricted
            numDep   = size(y,2);
            beta     = nan(numCoeff,numDep,iter);
            stdBeta  = nan(numCoeff,numDep,iter);
            residual = nan(T,numDep,iter);
            vcv      = nan(numDep,numDep,iter);
            
            % Estimate the covariance matrix
            kk = 1;
            for tt = start:T
                residual(ss(kk):tt,:,kk) = y(ss(kk):tt,:);
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
            beta       = zeros(numCoeff,numDep,iter);
            stdBeta    = nan(numCoeff,numDep,iter);
            stdType    = options.stdType;
            residual   = nan(T,numDep,iter);
            kk         = 1;
            vcv        = nan(numDep,numDep,iter);
            for tt = start:T

                if options.removeZeroRegressors
                    ind  = ~all(abs(X(ss(kk):tt,:)) < eps,1);
                    indA = [true(1,numCoeff - size(X,2)), ind];
                else
                    ind  = true(1,size(X,2));
                    indA = true(1,numCoeff);
                end

                [beta(indA,:,kk),stdBeta(indA,:,kk),~,~,residual(ss(kk):tt,:,kk)] = nb_ols(y(ss(kk):tt,:),X(ss(kk):tt,ind),constant,false,stdType);
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
            
        end
        
        % Add random walk parameter
        betaNI              = beta;
        stdBetaNI           = stdBeta;
        beta                = nan(numCoeff+1,numDep,iter);
        stdBeta             = nan(numCoeff+1,numDep,iter);
        indRW               = false(1,numCoeff+1);
        indRW(constant+1)   = true;
        beta(indRW,:,:)     = 1;
        beta(~indRW,:,:)    = betaNI;
        stdBeta(indRW,:,:)  = nan;
        stdBeta(~indRW,:,:) = stdBetaNI;
        
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
        % Shorten sample
        [options,y,X] = nb_estimator.testSample(options,y,X);

        % Check the degrees of freedom
        numCoeff = size(X,2) + options.constant;
        T        = size(X,1);
        nb_estimator.checkDOF(options,numCoeff,T);
        
        % Estimate model by ols
        %--------------------------------------------------
        if numCoeff == 0
            % All parameters are restricted
            numDep    = size(y,2);
            beta      = nan(numCoeff,numDep);
            stdBeta   = nan(numCoeff,numDep);
            tStatBeta = nan(numCoeff,numDep);
            pValBeta  = nan(numCoeff,numDep);
            residual  = y;
            XX        = [];
        else
            
            if options.removeZeroRegressors
                ind = ~all(abs(X) < eps);
            else
                ind = true(1,size(X,2));
            end
            [beta,stdBeta,tStatBeta,pValBeta,residual,XX] = nb_ols(y,X(:,ind),options.constant,false,options.stdType);
    
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
            indA                  = [true(1,numCoeff - size(X,2)), ind];
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
        
        % Add random walk parameter
        indRW                     = false(1,numCoeff+1);
        indRW(constant+1)         = true;
        betaNI                    = res.beta;
        res.beta                  = nan(numCoeff+1,numDep);
        res.beta(indRW,:,:)       = 1;
        res.beta(~indRW,:,:)      = betaNI;
        stdBetaNI                 = res.stdBeta;
        res.stdBeta               = nan(numCoeff+1,numDep);
        res.stdBeta(indRW,:,:)    = nan;
        res.stdBeta(~indRW,:,:)   = stdBetaNI;
        tStatBetaNI               = res.tStatBeta;
        res.tStatBeta             = nan(numCoeff+1,numDep);
        res.tStatBeta(indRW,:,:)  = nan;
        res.tStatBeta(~indRW,:,:) = tStatBetaNI;
        pValBetaNI                = res.pValBeta;
        res.pValBeta              = nan(numCoeff+1,numDep);
        res.pValBeta(indRW,:,:)   = nan;
        res.pValBeta(~indRW,:,:)  = pValBetaNI;
        
        % Get aditional test results
        %--------------------------------------------------
        if options.doTests
            ind             = options.estim_start_ind:options.estim_end_ind;
            yTest           = options.data(:,indY);
            yLag            = nb_lag(yTest,1);
            yTest           = yTest(ind,:);
            T               = size(y,1);
            yLag            = yLag(ind,:);
            XTest           = nan(T,numCoeff+1-constant);
            indRT           = indRW(constant+1:end);
            XTest(:,indRT)  = yLag;
            XTest(:,~indRT) = X;
            res             = nb_olsEstimator.doTest(res,options,res.beta,yTest,XTest,residual);
        end
        
    end
    
    % Assign generic results
    res.includedObservations = size(y,1);
    res.elapsedTime          = toc(tStart);
    
    % Assign results
    results = res;
    options.estimator = 'nb_rwEstimator';
    options.estimType = 'classic';

end

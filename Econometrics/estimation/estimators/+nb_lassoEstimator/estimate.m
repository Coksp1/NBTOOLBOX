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
%             the 'regularization' otpions.
%
% See also:
% nb_lassoEstimator.print, nb_lassoEstimator.help, 
% nb_lassoEstimator.template
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
    options = nb_defaultField(options,'addLags',true);
    options = nb_defaultField(options,'unbalanced',false);
    options = nb_defaultField(options,'removeZeroRegressors',false);
    options = nb_defaultField(options,'time_trend',false);
    options = nb_defaultField(options,'modelSelection',false);
    options = nb_defaultField(options,'covidAdj',{});
    options = nb_defaultField(options,'modelSelectionFixed',[]);
    options = nb_defaultField(options,'regularizationMode','normal');
    options = nb_defaultField(options,'regularizationPerc',[]);
    options = nb_defaultField(options,'restrictConstant',true);
    options = nb_defaultField(options,'nStep',0);
    
    if options.time_trend
        error('The time_trend options is not supported for LASSO estimation. Set it to false.')
    end
    if ~isempty(options.modelSelection)
        error('The modelSelection options is not supported for LASSO estimation. Set it to ''''.')
    end
    if isfield(options,'block_exogenous')
        if ~isempty(options.block_exogenous)
            error('Block exogenous variables are not supported by the lasso estimator.')
        end
    end
    
    % Check optimset
    if ~isfield(options,'optimset') || nb_isempty(options.optimset)
        options.optimset = nb_lasso.optimset();
    else
        defaultOptimset  = nb_lasso.optimset();
        fields           = fieldnames(options.optimset);
        defaultFields    = fieldnames(defaultOptimset);
        test             = ismember(defaultFields,fields);
        if any(~test)
            setFields = defaultFields(~test);
            for ii = 1:length(setFields)
                options.optimset.(setFields{ii}) = defaultOptimset.(setFields{ii});
            end
        end
    end

    % Check other inputs
    tempDep = cellstr(options.dependent);
    numDep  = length(tempDep);
    if options.nStep > 0
        numDep = numDep*options.nStep;
    end
    if ~isempty(options.regularization)
        if ~nb_isScalarNumber(options.regularization)
            if not(isvector(options.regularization) && length(options.regularization) == numDep)
                error(['The ''regularization'' option must either be a ',...
                    'scalar number or a vector with length ' int2str(numDep)])
            end
        end
    end
    if ~isempty(options.regularizationPerc)
        if ~nb_isScalarNumber(options.regularizationPerc)
            if not(isvector(options.regularizationPerc) && length(options.regularizationPerc) == numDep)
                error(['The ''regularizationPerc'' option must either be a ',...
                    'scalar number or a vector with length ' int2str(numDep)])
            end
        end
    end
    
    % Get the estimation data
    %------------------------------------------------------
    [y,X,~,options] = nb_estimator.preprareDataForEstimation(options);
    if size(X,2) == 0 && ~options.constant && ~options.time_trend
        error('You must select some regressors.')
    end

    % Do the estimation
    %------------------------------------------------------
    if options.recursive_estim

        if ~isempty(options.estim_types)
            error('Recursive estimation is only supported for time-series.')
        end
        
        % Shorten sample
        [options,y,X] = nb_estimator.testSample(options,y,X);

        % Ignore some covid dates?
        indCovid = nb_estimator.applyCovidFilter(options,y);

        % Check the sample
        numCoeff = size(X,2) + options.constant + options.time_trend;
        T        = size(y,1);
        [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,numCoeff,T);
            
        % Estimate the model recursively
        %--------------------------------------------------
        if options.nStep > 0
            numDep = size(y,2)*options.nStep;
        else
            numDep = size(y,2);
        end
        beta     = zeros(numCoeff,numDep,iter);
        stdBeta  = nan(numCoeff,numDep,iter);
        constant = options.constant;
        residual = nan(T - double(options.nStep>0),numDep,iter);
        reg      = nan(iter,numDep);
        regPerc  = nan(iter,numDep);
        kk       = 1;
        for tt = start:T

            % Remove zero regressors
            if options.removeZeroRegressors
                ind  = ~all(abs(X(ss(kk):tt,:)) < eps,1);
                indA = [true(1,numCoeff - size(X,2)), ind];
            else
                ind  = true(1,size(X,2));
                indA = true(1,numCoeff);
            end

            yEst = y(ss(kk):tt,:);
            XEst = X(ss(kk):tt,ind);

            if options.nStep > 0 % nb_sa models

                if ~isempty(indCovid)
                    indCovidTT = indCovid(ss(kk):tt,:);
                else
                    indCovidTT = [];
                end
                N = size(y,2);
                for ii = 1:N
                    indDep = ii:N:N*options.nStep;
                    [beta(indA,indDep,kk),stdBeta(indA,indDep,kk),~,~,res,...
                        ~,~,~,reg(kk,indDep),regPerc(kk,indDep)] = ...
                        nb_midasFunc(yEst(:,ii),XEst,constant,false,'lasso',...
                        options.nStep,'',length(options.uniqueExogenous),...
                        options.nLags,'draws',0,'remove',indCovidTT,...
                        'optimset',options.optimset,...
                        'regularization',options.regularization,...
                        'regularizationPerc',options.regularizationPerc,...
                        'restrictConstant',options.restrictConstant,...
                        'regularizationMode',options.regularizationMode);

                    residual(ss(kk):tt-1,indDep,kk) = res;
                end

            else

                if ~isempty(indCovid)
                    % Strip covid dates from estimation
                    yEstCov = yEst(~indCovid(ss(kk):tt,:),:);
                    XEstCov = XEst(~indCovid(ss(kk):tt,:),:);
                    yEst    = yEst(indCovid(ss(kk):tt,:),:);
                    XEst    = XEst(indCovid(ss(kk):tt,:),:);
                end

                % Do estimation
                [beta(indA,:,kk),exitflag,res,~,reg(kk,:),regPerc(kk,:)] = ...
                    nb_lasso(yEst,XEst,options.regularization,constant,...
                    options.optimset,'tPerc',options.regularizationPerc,...
                    'restrictConstant',options.restrictConstant,...
                    'mode',options.regularizationMode);
                if exitflag < 0
                    nb_interpretExitFlag(exitflag,'nb_lasso',[' Failed during ',...
                        'LASSO estimation for iteration ' int2str(kk)])
                end

                if ~isempty(indCovid)
                    res = nb_estimator.predictResidual(yEstCov,XEstCov,...
                        constant,false,beta(indA,:,kk),res,...
                        indCovid(ss(kk):tt,:));
                end
                residual(ss(kk):tt,:,kk) = res;

            end

            % Set starting values for next iteration
            kk = kk + 1;
            
        end

        % Estimate the covariance matrix
        %--------------------------------
        vcv = nb_estimator.estimateCovarianceMatrixDuringRecEst(...
            options,residual,indCovid,start,T,ss,numCoeff);
        
        % Get estimation results
        %--------------------------------------------------
        results                    = struct();
        results.beta               = beta;
        results.stdBeta            = stdBeta;
        results.sigma              = vcv;
        results.residual           = residual;
        results.regularization     = reg;
        results.regularizationPerc = regPerc;
        
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

            % Ignore some covid dates?
            indCovid = nb_estimator.applyCovidFilter(options,y);

        else
            
            numCoeff = size(X,2) + options.constant;
            N        = size(X,1);
            nb_estimator.checkDOF(options,numCoeff,N);
            
            % Secure that the data is balanced
            testData = [y,X];
            testData = testData(:);
            if any(isnan(testData))
                error('The estimation data is not balanced.')
            end
            indCovid = [];
            
        end
        
        % Estimate model by lasso
        %-------------------------------------------------- 
        if options.removeZeroRegressors
            ind = ~all(abs(X) < eps);
        else
            ind = true(1,size(X,2));
        end
        yEst = y;
        XEst = X(:,ind);

        if options.nStep > 0

            if options.removeZeroRegressors
                indA = [true(1,numCoeff - size(XRest,2)), ind];
            else
                indA = true(1,numCoeff);
            end

            N         = size(y,2);
            numDep    = N*options.nStep;
            beta      = zeros(numCoeff,numDep);
            stdBeta   = nan(numCoeff,numDep);
            residual  = nan(size(y,1) - 1,numDep);
            reg       = nan(1,numDep);
            regPerc   = nan(1,numDep);
            for ii = 1:N
                indDep = ii:N:N*options.nStep;
                [beta(indA,indDep),stdBeta(indA,indDep),~,~,...
                    residual(:,indDep),~,~,~,reg(:,indDep),regPerc(:,indDep)] = ...
                    nb_midasFunc(yEst(:,ii),XEst,options.constant,false,'lasso',...
                    options.nStep,options.stdType,length(options.uniqueExogenous),...
                    options.nLags,'draws',0,'remove',indCovid,...
                    'optimset',options.optimset,...
                    'regularization',options.regularization,...
                    'regularizationPerc',options.regularizationPerc,...
                    'restrictConstant',options.restrictConstant,...
                    'regularizationMode',options.regularizationMode);
            end
            
            XX = [];

            % Strip residual
            residualStripped = nb_estimator.stripSteapAheadResiduals(...
                options,residual,indCovid);
            
        else

            if ~isempty(indCovid)
                yEstCov = yEst(~indCovid,:);
                XEstCov = XEst(~indCovid,:);
                yEst    = y(indCovid,:);
                XEst    = X(indCovid,ind);
            end
    
            [beta,exitflag,residual,XX,reg,regPerc] = nb_lasso(yEst,XEst,...
                options.regularization,options.constant,options.optimset,...
                'tPerc',options.regularizationPerc,...
                'restrictConstant',options.restrictConstant,...
                'mode',options.regularizationMode);
            if exitflag < 0
                nb_interpretExitFlag(exitflag,'nb_lasso',...
                    ' Failed during LASSO estimation')
            end
            stdBeta = nan(size(beta));
    
            residualStripped = residual;
            if ~isempty(indCovid)
                residual = nb_estimator.predictResidual(yEstCov,XEstCov,...
                    options.constant,false,beta,residual,indCovid);
            end

        end
        
        % Estimate the covariance matrix
        %-------------------------------
        T     = size(residualStripped,1);
        sigma = residualStripped'*residualStripped/(T - numCoeff);
        
        % Get estimation results
        %--------------------------------------------------
        results = struct();
        if options.removeZeroRegressors && options.nStep == 0
            numEq                     = size(y,2);
            indA                      = [true(1,numCoeff - size(X,2)), ind];
            results.beta              = zeros(numCoeff,numEq);
            results.beta(indA,:)      = beta;
            results.stdBeta           = nan(numCoeff,numEq);
            results.stdBeta(indA,:)   = stdBeta; 
        else
            results.beta    = beta;
            results.stdBeta = stdBeta;
        end
        results.residual = residual;
        results.sigma    = sigma;
        if options.nStep > 0
            yLead             = nb_mlead(y,options.nStep,'varFast');
            yLead             = yLead(1:end-1,:);
            results.predicted = yLead - residual;
        else
            results.predicted = y - residual;
        end
        results.regressors         = XX;
        results.regularization     = reg;
        results.regularizationPerc = regPerc;
        
    end
    
    % Wrap up estimation
    [options,results] = nb_estimator.wrapUpEstimation(options,results,...
        'nb_lassoEstimator','classic',y,tStart);

end

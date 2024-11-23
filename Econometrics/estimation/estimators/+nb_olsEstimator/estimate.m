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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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
    options = nb_defaultField(options,'covidAdj',{});
    options = nb_defaultField(options,'nStep',0);
    
    if ~ismember(options.stdType,{'h','w','nw'})
        options.stdType = 'h';
    end
    
    % Get the estimation data
    %------------------------------------------------------
    [y,X,blockRest,options] = nb_estimator.preprareDataForEstimation(options);
    
    % Apply restrictions
    if ~isempty(options.restrictions)
        [yRest,XRest,restrict] = nb_estimator.applyRestrictions(options,y,X);
    else
        yRest = y;
        XRest = X;
    end

    % Do the estimation
    %------------------------------------------------------

    if options.recursive_estim

        if ~isempty(options.estim_types)
            error('Recursive estimation is only supported for time-series.')
        end
        
        % Shorten sample
        [options,yRest,XRest] = nb_estimator.testSample(options,yRest,XRest);

        % Ignore some covid dates?
        indCovid = nb_estimator.applyCovidFilter(options,yRest);

        % Check the sample
        numCoeff = size(XRest,2) + options.constant + options.time_trend;
        T        = size(yRest,1);
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
            if options.nStep > 0
                numDep = size(yRest,2)*options.nStep;
            else
                numDep = size(yRest,2);
            end
            beta       = zeros(numCoeff,numDep,iter);
            stdBeta    = nan(numCoeff,numDep,iter);
            constant   = options.constant;
            time_trend = options.time_trend;
            stdType    = options.stdType;
            residual   = nan(T - double(options.nStep>0),numDep,iter);
            kk         = 1;
            if isempty(blockRest)
                for tt = start:T
                    
                    if options.removeZeroRegressors
                        ind  = ~all(abs(XRest(ss(kk):tt,:)) < eps,1);
                        indA = [true(1,numCoeff - size(XRest,2)), ind];
                    else
                        ind  = true(1,size(XRest,2));
                        indA = true(1,numCoeff);
                    end

                    yEst = yRest(ss(kk):tt,:);
                    XEst = XRest(ss(kk):tt,ind);

                    if options.nStep > 0 % nb_sa models

                        if ~isempty(indCovid)
                            indCovidTT = indCovid(ss(kk):tt,:);
                        else
                            indCovidTT = [];
                        end
                        N = size(yRest,2);
                        for ii = 1:N
                            indDep = ii:N:N*options.nStep;
                            [beta(indA,indDep,kk),stdBeta(indA,indDep,kk),~,~,res] = ...
                                nb_midasFunc(yEst(:,ii),XEst,constant,false,'unrestricted',...
                                options.nStep,stdType,length(options.uniqueExogenous),...
                                options.nLags,'draws',0,'remove',indCovidTT);

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
    
                        [beta(indA,:,kk),stdBeta(indA,:,kk),~,~,res] = ...
                            nb_ols(yEst,XEst,constant,time_trend,stdType);

                        if ~isempty(indCovid)
                            res = nb_estimator.predictResidual(yEstCov,XEstCov,...
                                constant,time_trend,beta(indA,:,kk),res,...
                                indCovid(ss(kk):tt,:));
                        end
                        residual(ss(kk):tt,:,kk) = res;
    
                    end
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

                    yEst = yRest(ss(kk):tt,:);
                    XEst = XRest(ss(kk):tt,ind);
                    if ~isempty(indCovid)
                        % Strip covid dates from estimation
                        yEstCov = yEst(~indCovid(ss(kk):tt,:),:);
                        XEstCov = XEst(~indCovid(ss(kk):tt,:),:);
                        yEst    = yEst(indCovid(ss(kk):tt,:),:);
                        XEst    = XEst(indCovid(ss(kk):tt,:),:);
                    end

                    blockRestIndexed = indexBlockRest(options,blockRest,ind);

                    [beta(indA,:,kk),stdBeta(indA,:,kk),~,~,res] = ...
                        nb_olsRestricted(yEst,XEst,blockRestIndexed,constant,time_trend,stdType);
                    
                    if ~isempty(indCovid)
                        res = nb_estimator.predictResidual(yEstCov,XEstCov,...
                            constant,time_trend,beta(indA,:,kk),res,...
                            indCovid(ss(kk):tt,:));
                    end
                    residual(ss(kk):tt,:,kk) = res;
                    
                    kk = kk + 1;
                end
            end
            
            % Estimate the covariance matrix
            %--------------------------------
            vcv = nb_estimator.estimateCovarianceMatrixDuringRecEst(...
                options,residual,indCovid,start,T,ss,numCoeff);
            
        end
        
        % Get estimation results
        %--------------------------------------------------
        results          = struct();
        results.beta     = beta;
        results.stdBeta  = stdBeta;
        results.sigma    = vcv;
        results.residual = residual;
        
        % Add restrictions to results
        if ~isempty(options.restrictions)
            results = nb_estimator.addRestrictions(options,results,restrict);
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

            % Ignore some covid dates?
            indCovid = nb_estimator.applyCovidFilter(options,yRest);

        else
            
            numCoeff = size(XRest,2) + options.constant;
            N        = size(XRest,1);
            nb_estimator.checkDOF(options,numCoeff,N);
            
            % Secure that the data is balanced
            %------------------------------------------------------
            testData = [yRest,XRest];
            testData = testData(:);
            if any(isnan(testData))
                error('The estimation data is not balanced.')
            end
            indCovid = [];
            
        end
        
        % Estimate model by ols
        %--------------------------------------------------
        if numCoeff == 0
            % All parameters are restricted
            numDep           = size(yRest,2);
            beta             = nan(numCoeff,numDep);
            stdBeta          = nan(numCoeff,numDep);
            tStatBeta        = nan(numCoeff,numDep);
            pValBeta         = nan(numCoeff,numDep);
            residual         = yRest;
            residualStripped = residual;
            XX               = [];
        else
            
            if options.removeZeroRegressors
                ind  = ~all(abs(XRest) < eps);
            else
                ind  = true(1,size(XRest,2));
            end
            yEst = yRest;
            XEst = XRest(:,ind);

            if options.nStep > 0

                if options.removeZeroRegressors
                    indA = [true(1,numCoeff - size(XRest,2)), ind];
                else
                    indA = true(1,numCoeff);
                end

                N         = size(yRest,2);
                numDep    = N*options.nStep;
                beta      = zeros(numCoeff,numDep);
                stdBeta   = nan(numCoeff,numDep);
                tStatBeta = zeros(numCoeff,numDep);
                pValBeta  = nan(numCoeff,numDep);
                residual  = nan(size(yRest,1) - 1,numDep);
                for ii = 1:N
                    indDep = ii:N:N*options.nStep;
                    [beta(indA,indDep),stdBeta(indA,indDep),tStatBeta(indA,indDep),...
                        pValBeta(indA,indDep),residual(:,indDep)] = ...
                        nb_midasFunc(yEst(:,ii),XEst,options.constant,false,'unrestricted',...
                        options.nStep,options.stdType,length(options.uniqueExogenous),...
                        options.nLags,'draws',0,'remove',indCovid);
                end
                
                XX = [];

                % Strip residual
                [residualStripped,stripInd] = nb_estimator.stripSteapAheadResiduals(...
                    options,residual,indCovid);
                
            else

                if ~isempty(indCovid)
                    yEstCov = yEst(~indCovid,:);
                    XEstCov = XEst(~indCovid,:);
                    yEst    = yEst(indCovid,:);
                    XEst    = XEst(indCovid,:);
                end
                
                if isempty(blockRest)
                    [beta,stdBeta,tStatBeta,pValBeta,residual,XX] = ...
                        nb_ols(yEst,XEst,options.constant,options.time_trend,options.stdType);
                else
                    blockRestIndexed = indexBlockRest(options,blockRest,ind);
                    [beta,stdBeta,tStatBeta,pValBeta,residual,XX] = ...
                        nb_olsRestricted(yEst,XEst,blockRestIndexed,...
                        options.constant,options.time_trend,options.stdType);
                end

                residualStripped = residual;
                if ~isempty(indCovid)
                    residual = nb_estimator.predictResidual(yEstCov,XEstCov,...
                        options.constant,options.time_trend,beta,residual,...
                        indCovid);
                end

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
            indA                      = [true(1,numCoeff - size(XRest,2)), ind];
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
        results.residual = residual;
        results.sigma    = sigma;
        if options.nStep > 0
            yLead         = nb_mlead(y,options.nStep,'varFast');
            yLead         = yLead(1:end-1,:);
            results.predicted = yLead - residual;
        else
            results.predicted = y - residual;
        end
        results.regressors = XX;
        
        % Add restrictions to results
        if ~isempty(options.restrictions)
            results = nb_estimator.addRestrictions(options,results,restrict);
        end
        
        % Get aditional test results
        %--------------------------------------------------
        if options.doTests
            if isempty(indCovid)
                if options.nStep == 0
                    yTest = y;
                    XTest = X;
                else
                    yTest = yLead(~stripInd,:);
                    XTest = yLead(~stripInd,:);
                end
            else
                if options.nStep == 0
                    yTest = y(indCovid,:);
                    XTest = X(indCovid,:);
                else
                    yTest = yLead(~stripInd,:);
                    XTest = yLead(~stripInd,:);
                end
            end
            results = nb_olsEstimator.doTest(results,options,results.beta,yTest,...
                XTest,residualStripped);
        end
        
    end
    
    % Wrap up estimation
    [options,results] = nb_estimator.wrapUpEstimation(options,results,...
        'nb_olsEstimator','classic',yRest,tStart);

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

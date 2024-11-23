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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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
    options = nb_defaultField(options,'covidAdj',{});
    options = nb_defaultField(options,'addLags',true);
    if any(strcmpi(options.stdType,{'h','nw','w'}))
        options.stdType = 'sparsity';
    end
    
    % Get the estimation data
    %------------------------------------------------------
    [y,X,blockRest,options] = nb_estimator.preprareDataForEstimation(options);
    if size(X,2) == 0 && ~options.constant && ~options.time_trend
        error('You must select some regressors.')
    end

    % Do the estimation
    %------------------------------------------------------
    q = options.quantile;
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
        N = size(y,2);
        if options.nStep > 0
            numDep = N*options.nStep;
        else
            numDep = N;
        end
        beta       = zeros(numCoeff,numDep,length(q),iter);
        stdBeta    = nan(numCoeff,numDep,length(q),iter);
        constant   = options.constant;
        time_trend = options.time_trend;
        stdType    = options.stdType;
        residual   = nan(T - double(options.nStep>0),numDep,length(q),iter);
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

            yEst = y(ss(kk):tt,:);
            XEst = X(ss(kk):tt,ind);

            if options.nStep > 0 % nb_sa models

                for ii = 1:options.nStep

                    indLead  = (ii - 1)*N + 1:ii*N;
                    yEstLead = lead(yEst,ii);
                    yEstLead = yEstLead(1:end-ii,:);
                    XEstLead = XEst(1:end-ii,:);

                    if ~isempty(indCovid)
                        % Strip covid dates from estimation, restricted
                        % to one dependent in this case!!
                        indCovidTT  = indCovid(ss(kk):tt,:);
                        remThisStep = lead(indCovidTT(:,1),ii);
                        remThisStep = remThisStep(1:end-ii) & indCovidTT(1:end-ii,2);
                        yEstLeadCov = yEstLead(~remThisStep,:);
                        XEstLeadCov = XEstLead(~remThisStep,:);
                        yEstLead    = yEstLead(remThisStep,:);
                        XEstLead    = XEstLead(remThisStep,:);
                    end
            
                    [beta(indA,indLead,:,kk),stdBeta(indA,indLead,:,kk),~,~,res] = ...
                        nb_qreg(q,yEstLead,XEstLead,constant,time_trend,...
                        stdType,1000,blockRest,options.waitbar);

                    if ~isempty(indCovid)
                        res = nb_estimator.predictResidual(yEstLeadCov,XEstLeadCov,...
                            constant,time_trend,beta(indA,indLead,:,kk),res,...
                            remThisStep);
                    end
                    residual(ss(kk):tt-ii,indLead,:,kk) = res;

                end

            else

                if ~isempty(indCovid)
                    % Strip covid dates from estimation
                    yEstCov = yEst(~indCovid(ss(kk):tt,:),:);
                    XEstCov = XEst(~indCovid(ss(kk):tt,:),:);
                    yEst    = yEst(indCovid(ss(kk):tt,:),:);
                    XEst    = XEst(indCovid(ss(kk):tt,:),:);
                end
            
                [beta(indA,:,:,kk),stdBeta(indA,:,:,kk),~,~,res] = ...
                    nb_qreg(q,yEst,XEst,constant,time_trend,...
                    stdType,1000,blockRest,options.waitbar);

                if ~isempty(indCovid)
                    res = nb_estimator.predictResidual(yEstCov,XEstCov,...
                        constant,time_trend,beta(indA,:,kk),res,...
                        indCovid(ss(kk):tt,:));
                end
                residual(ss(kk):tt,:,:,kk) = res;

            end

            if waitbar 
                nb_estimator.notifyWaitbar(h,kk,iter,note)
            end
            kk = kk + 1; 
            
        end
        
        % Estimate the covariance matrix
        %--------------------------------
        residual = permute(residual,[1,2,4,3]);
        vcv      = nb_estimator.estimateCovarianceMatrixDuringRecEst(...
            options,residual,indCovid,start,T,ss,numCoeff);

        % Get estimation results
        %--------------------------------------------------
        results          = struct();
        results.beta     = permute(beta,[1,2,4,3]);
        results.stdBeta  = permute(stdBeta,[1,2,4,3]);
        results.sigma    = vcv;
        results.residual = residual;
        
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

            % Ignore some covid dates?
            indCovid = nb_estimator.applyCovidFilter(options,y);

        else
            
            numCoeff = size(X,2) + options.constant;
            N        = size(X,1);
            nb_estimator.checkDOF(options,numCoeff,N);
            
            % Secure that the data is balanced
            %------------------------------------------------------
            testData = [y,X];
            testData = testData(:);
            if any(isnan(testData))
                error('The estimation data is not balanced.')
            end
            indCovid = [];
            
        end
        
        % Estimate model by quantile regression
        %--------------------------------------------------
        if options.removeZeroRegressors
            ind  = ~all(abs(X) < eps);
        else
            ind  = true(1,size(X,2));
        end
        
        yEst = y;
        XEst = X(:,ind);

        if options.nStep > 0 % nb_sa models

            if options.removeZeroRegressors
                indA = [true(1,numCoeff - size(XRest,2)), ind];
            else
                indA = true(1,numCoeff);
            end

            N                = size(y,2);
            numDep           = N*options.nStep;
            beta             = zeros(numCoeff,numDep,length(q));
            stdBeta          = nan(numCoeff,numDep,length(q));
            tStatBeta        = nan(numCoeff,numDep,length(q));
            pValBeta         = nan(numCoeff,numDep,length(q));
            residual         = nan(size(y,1) - 1,numDep,length(q));
            residualStripped = nan(size(y,1) - 1,numDep,length(q));
            for ii = 1:options.nStep

                indLead  = (ii - 1)*N + 1:ii*N;
                yEstLead = lead(yEst,ii);
                yEstLead = yEstLead(1:end-ii,:);
                XEstLead = XEst(1:end-ii,:);

                if ~isempty(indCovid)
                    % Strip covid dates from estimation, restricted
                    % to one dependent in this case!!
                    remThisStep = lead(indCovid(:,1),ii);
                    remThisStep = remThisStep(1:end-ii) & indCovid(1:end-ii,2);
                    yEstLeadCov = yEstLead(~remThisStep,:);
                    XEstLeadCov = XEstLead(~remThisStep,:);
                    yEstLead    = yEstLead(remThisStep,:);
                    XEstLead    = XEstLead(remThisStep,:);
                end
        
                [beta(indA,indLead,:),stdBeta(indA,indLead,:),...
                    tStatBeta(indA,indLead,:),pValBeta(indA,indLead,:),res] = ...
                    nb_qreg(q,yEstLead,XEstLead,options.constant,options.time_trend,...
                    options.stdType,1000,blockRest,options.waitbar);

                if ~isempty(indCovid)
                    resS                  = nan(size(remThisStep,1),size(res,2),size(res,3));
                    resS(remThisStep,:,:) = res;

                    res = nb_estimator.predictResidual(yEstLeadCov,XEstLeadCov,...
                        options.constant,options.time_trend,beta(indA,indLead,:),res,...
                        remThisStep);
                else
                    resS = res;
                end
                residualStripped(1:end-ii+1,indLead,:) = resS;
                residual(1:end-ii+1,indLead,:)         = res;
                XX                                     = [];

            end

            indStrip                       = any(any(isnan(residualStripped),2),3);
            residualStripped(indStrip,:,:) = [];
            
        else

            if ~isempty(indCovid)
                yEstCov = yEst(indCovid,:);
                XEstCov = XEst(indCovid,ind);
                yEst    = yEst(indCovid,:);
                XEst    = XEst(indCovid,ind);
            end

            [beta,stdBeta,tStatBeta,pValBeta,residual,XX] = nb_qreg(q,yEst,XEst,...
                options.constant,options.time_trend,options.stdType,1000,...
                blockRest,options.waitbar);

            residualStripped = residual;
            if ~isempty(indCovid)
                residual = nb_estimator.predictResidual(yEstCov,XEstCov,...
                    options.constant,options.time_trend,beta,residual,...
                    indCovid);
            end

        end
        
        % Estimate the covariance matrix
        %-------------------------------
        E     = size(beta,2);
        sigma = nan(E,E,1,length(q)); 
        for qq = 1:length(q)
            resid           = residualStripped(:,:,qq);
            residClean      = bsxfun(@minus,resid,mean(resid,1));
            sigma(:,:,:,qq) = residClean'*residClean/(size(residClean,1) - numCoeff);
        end
        
        % Get estimation results (parameters for each quantile is added 
        % in the 4th dimension)
        %------------------------------------------------------------------
        results = struct();
        if options.removeZeroRegressors && options.nStep == 0
            numEq                         = size(y,2);
            indA                          = [true(1,numCoeff - size(X,2)), ind];
            results.beta                  = zeros(numCoeff,numEq,1,length(q));
            results.beta(indA,:,:,:)      = permute(beta,[1,2,4,3]);
            results.stdBeta               = nan(numCoeff,numEq,1,length(q));
            results.stdBeta(indA,:,:,:)   = permute(stdBeta,[1,2,4,3]); 
            results.tStatBeta             = nan(numCoeff,numEq,1,length(q));
            results.tStatBeta(indA,:,:,:) = permute(tStatBeta,[1,2,4,3]);
            results.pValBeta              = nan(numCoeff,numEq,1,length(q));
            results.pValBeta(indA,:,:,:)  = permute(pValBeta,[1,2,4,3]);
        else
            results.beta       = permute(beta,[1,2,4,3]);
            results.stdBeta    = permute(stdBeta,[1,2,4,3]);
            results.tStatBeta  = permute(tStatBeta,[1,2,4,3]);
            results.pValBeta   = permute(pValBeta,[1,2,4,3]);
        end
        
        results.residual = permute(residual,[1,2,4,3]);
        results.sigma    = sigma;
        if options.nStep > 0
            yLead             = nb_mlead(y,options.nStep,'varFast');
            yLead             = yLead(1:end-1,:);
            results.predicted = bsxfun(@minus,yLead,results.residual);
        else
            results.predicted  = bsxfun(@minus,y,results.residual);
        end
        results.regressors = XX;
        
    end
    
    % Wrap up estimation
    [options,results] = nb_estimator.wrapUpEstimation(options,results,...
        'nb_quantileEstimator','classic',y,tStart);

end


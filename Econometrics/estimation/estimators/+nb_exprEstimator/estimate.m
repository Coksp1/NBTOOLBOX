function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_exprEstimator.estimate(options)
%
% Description:
%
% Estimate a model with ols.
% 
% Input:
% 
% - options  : A struct on the format given by nb_exprEstimator.template.
%              See also nb_exprEstimator.help.
% 
% Output:
% 
% - result : A struct with the estimation results.
%
% - options : The return model options.
%
% See also:
% nb_exprEstimator.print, nb_exprEstimator.help, nb_exprEstimator.template
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
    options = nb_defaultField(options,'covidAdj',{});
    options = nb_defaultField(options,'nStep',0);

    if ~ismember(options.stdType,{'h','w','nw'})
        options.stdType = 'h';
    end
    
    % Get the estimation options
    %------------------------------------------------------
    tempDep = cellstr(options.dependent);
    if isempty(tempDep)
        error(['No dependent variables (expressions) selected, please ',...
            'assign the dependent field of the options property.'])
    end
    if isempty(options.data)
        error('Cannot estimate without data.')
    end

    % Interpret the expression
    %------------------------------------------------------
    nDep = length(options.dependent);
    if ~isfield(options,'depFuncs')
        depFuncs = cell(1,nDep);
        depOrig  = cell(1,nDep);
        for ii = 1:nDep
            [depFuncs{ii},~,depOrig(ii)] = nb_exprEstimator.eqs2funcSub(...
                options.dataVariables,options.dependent{ii},true);
        end
        options.depFuncs      = depFuncs;
        options.dependentOrig = depOrig; 
    else
        depFuncs = options.depFuncs;
        depOrig  = options.dependentOrig;
    end
    
    if ~isfield(options,'exoFuncs')
        maxLags = 0;
        minLags = inf;
        indCont = logical(eye(nDep,nDep));
        if ~isempty(options.exogenous)

            if iscell(options.exogenous{1})
                if length(options.exogenous) ~= nDep
                    error(['If exogenous is a nested cell it has to have ',...
                        'the same length as the number of dependent ',...
                        'expressions (' int2str(nDep) ').'])
                end
                nDep     = length(options.dependent);
                exoFuncs = cell(1,nDep);
                vars     = cell(1,nDep);
                for ii = 1:nDep
                    if ischar(options.exogenous{ii})
                        options.exogenous{ii} = options.exogenous(ii);
                    end
                    nExoOne     = length(options.exogenous{ii});
                    exoFuncsOne = cell(1,nExoOne);
                    varsOne     = cell(1,nExoOne);
                    for jj = 1:nExoOne
                        [exoFuncsOne{jj},nLags,varsOne{jj}] = nb_exprEstimator.eqs2funcSub(...
                            options.dataVariables,options.exogenous{ii}{jj},false);
                        [maxLags,minLags,indContOne] = updateLags(...
                            maxLags,minLags,nLags,varsOne{jj},depOrig);
                        indCont(ii,:) = indCont(ii,:) | indContOne;
                    end
                    exoFuncs{ii} = exoFuncsOne;
                    vars{ii}     = varsOne;
                end
            else
                nExo     = length(options.exogenous);
                exoFuncs = cell(1,nExo);
                vars     = cell(1,nExo);
                for ii = 1:nExo
                    [exoFuncs{ii},nLags,vars{ii}]  = nb_exprEstimator.eqs2funcSub(options.dataVariables,options.exogenous{ii},false);
                    [maxLags,minLags,indCont(ii,:)] = updateLags(maxLags,minLags,nLags,vars{ii},depOrig);
                end
                exoFuncs          = repmat({exoFuncs},[1,nDep]);
                options.exogenous = repmat({options.exogenous},[1,nDep]);
            end

        end
        options.exoFuncs      = exoFuncs;
        options.nLags         = maxLags;
        options.minLags       = minLags;
        options.exogenousOrig = setdiff(nb_nestedCell2Cell(vars),depOrig);
        options.indCont       = double(indCont);
    else
        exoFuncs = options.exoFuncs;
        maxLags  = options.nLags;
    end
    
    % Get the estimation data
    yEq      = cell(1,nDep);
    XEq      = cell(1,nDep);
    nExo     = nan(1,nDep);
    Z        = options.data;
    T        = size(Z,1);
    timespan = maxLags+1:T;
    for ii = 1:nDep
        y             = nan(T,1);
        y(timespan,1) = depFuncs{ii}(Z,timespan);
        exoFuncsOne   = exoFuncs{ii};
        nExo(ii)      = size(exoFuncsOne,2);
        X             = nan(T,nExo(ii));
        for jj = 1:nExo(ii)
            X(timespan,jj) = exoFuncsOne{jj}(Z,timespan);
        end
        yEq{ii} = y;
        XEq{ii} = X;
    end
    options.nExo = nExo;
    
    % Decide the estimation sample
    [options,yAll,XAll] = nb_estimator.testSample(options,[yEq{:}],[XEq{:}]);
    numCoeff            = max(nExo) + options.constant + options.time_trend;
    T                   = size(yAll,1);
    if options.recursive_estim
        
        % Check the sample
        [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,numCoeff,T);
            
    else
        
        % Check the degrees of freedom
        iter  = 1;
        start = T;
        ss    = 1;
        nb_estimator.checkDOF(options,numCoeff,T);
        
    end

    % Ignore some covid dates?
    indCovid = nb_estimator.applyCovidFilter(options,yAll);
    
    % Preallocation
    results.beta                 = cell(1,nDep);
    results.stdBeta              = cell(1,nDep);
    results.residual             = nan(T,nDep,iter);
    results.includedObservations = nan(1,nDep);
    if ~options.recursive_estim
        results.tStatBeta = cell(1,nDep);
        results.pValBeta  = cell(1,nDep);
        results.predicted = nan(T,nDep,iter);
        results.XX        = cell(1,nDep);
        results.tests     = cell(1,nDep);
    end
    
    % Loop each equation
    exoInd = 1;
    for ii = 1:nDep
    
        % Get data of this equation
        y      = yAll(:,ii);
        X      = XAll(:,exoInd:exoInd + nExo(ii) - 1);
        exoInd = exoInd + nExo(ii);
        
        % Do the estimation
        %------------------------------------------------------
        
        if options.recursive_estim

            % Estimate the model recursively
            %--------------------------------------------------
            nCoeff     = nExo(ii) + options.constant + options.time_trend;
            beta       = zeros(nCoeff,1,iter);
            stdBeta    = nan(nCoeff,1,iter);
            constant   = options.constant;
            time_trend = options.time_trend;
            stdType    = options.stdType;
            residual   = nan(T,1,iter);
            kk         = 1;
            for tt = start:T
                
                if options.removeZeroRegressors
                    ind  = ~all(abs(X(ss(kk):tt,:)) < eps,1);
                    indA = [true(1,nCoeff - size(X,2)), ind];
                else
                    ind  = true(1,size(X,2));
                    indA = true(1,nCoeff);
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
                
                [beta(indA,:,kk),stdBeta(indA,:,kk),~,~,res] = ...
                    nb_ols(yEst,XEst,constant,time_trend,stdType);

                if ~isempty(indCovid)
                    res = nb_estimator.predictResidual(yEstCov,XEstCov,...
                        constant,time_trend,beta(indA,:,kk),res,...
                        indCovid(ss(kk):tt,:));
                end
                residual(ss(kk):tt,:,kk) = res;

                kk = kk + 1;
                
            end
            
            % Get estimation results
            %--------------------------------------------------
            results.beta{ii}         = beta;
            results.stdBeta{ii}      = stdBeta;
            results.residual(:,ii,:) = residual;

        %======================
        else % Not recursive
        %======================
        
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

            if ~isempty(indCovid)
                residual = nb_estimator.predictResidual(yEstCov,XEstCov,...
                    options.constant,options.time_trend,beta,residual,...
                    indCovid);
            end

            if options.removeZeroRegressors
                nCoeff             = nExo(ii) + options.constant + options.time_trend;
                numEq              = size(y,2);
                indA               = [true(1,nCoeff - size(X,2)), ind];
                betaT              = zeros(nCoeff,numEq);
                betaT(indA,:)      = beta;
                beta               = betaT;
                stdBetaT           = nan(nCoeff,numEq);
                stdBetaT(indA,:)   = stdBeta; 
                stdBeta            = stdBetaT;
                tStatBetaT         = nan(nCoeff,numEq);
                tStatBetaT(indA,:) = tStatBeta;
                tStatBeta          = tStatBetaT;
                pValBetaT          = nan(nCoeff,numEq);
                pValBetaT(indA,:)  = pValBeta;
                pValBeta           = pValBetaT;
            end
            
            % Get estimation results
            %--------------------------------------------------
            results.beta{ii}        = beta;
            results.stdBeta{ii}     = stdBeta;
            results.tStatBeta{ii}   = tStatBeta;
            results.pValBeta{ii}    = pValBeta;
            results.residual(:,ii)  = residual;
            results.predicted(:,ii) = y - residual;
            results.regressors{ii}  = XX;

            % Get aditional test results
            %--------------------------------------------------
            if options.doTests
                yTest = y;
                XTest = X;
                rTest = residual;
                if ~isempty(indCovid)
                    yTest = yTest(indCovid,:);
                    XTest = XTest(indCovid,:);
                    rTest = rTest(indCovid,:);
                end
                results.tests{ii} = nb_olsEstimator.doTest(results.tests{ii},...
                    options,beta,yTest,XTest,rTest);
            end

        end
        
        results.includedObservations(ii) = size(y,1);
        
    end
    
    % Estimate the covariance matrix
    %--------------------------------
    sigma = nan(nDep,nDep,iter);
    kk    = 1;
    for tt = start:T
        resid = results.residual(ss(kk):tt,:,kk);
        if ~isempty(indCovid)
            indCovidTT = indCovid(ss(kk):tt);
            resid      = resid(indCovidTT,:);
        end
        sigma(:,:,kk) = resid'*resid/(size(resid,1) - numCoeff);
        kk            = kk + 1;
    end
    results.sigma = sigma;
    
    % Assign generic results
    results.elapsedTime = toc(tStart);
    
    % Assign results
    options.estimator = 'nb_exprEstimator';
    options.estimType = 'classic';

end

%==========================================================================
function [maxLags,minLags,indDep] = updateLags(maxLags,minLags,nLags,vars,depOrig)

    mxLags = max(nLags);
    if mxLags > maxLags
        maxLags = mxLags;
    end
    ind    = ismember(vars,depOrig);
    mnLags = min(nLags(ind));
    if ~isempty(mnLags)
        if mnLags < minLags
            minLags = mnLags;
        end
    end
    
    % Get contemporanous index 
    indDep = ismember(depOrig,vars(nLags == 0));
    
end

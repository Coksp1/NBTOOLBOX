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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end
    options = nb_defaultField(options,'class','');
    options = nb_defaultField(options,'requiredDegreeOfFreedom',3);
    options = nb_defaultField(options,'seasonalDummy','');
    options = nb_defaultField(options,'removeZeroRegressors',false);
    if ~ismember(options.stdType,{'h','w','nw'})
        options.stdType = 'h';
    end
    
    % Get the estimation options
    %------------------------------------------------------
    tempDep = cellstr(options.dependent);
    if isempty(tempDep)
        error([mfilename ':: No dependent variables (expressions) selected, please assign the dependent field of the options property.'])
    end
    if isempty(options.data)
        error([mfilename ':: Cannot estimate without data.'])
    end

    % Interpret the expression
    %------------------------------------------------------
    nDep = length(options.dependent);
    if ~isfield(options,'depFuncs')
        depFuncs = cell(1,nDep);
        depOrig  = cell(1,nDep);
        for ii = 1:nDep
            [depFuncs{ii},~,depOrig(ii)] = nb_exprEstimator.eqs2funcSub(options.dataVariables,options.dependent{ii},true);
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
                    error([mfilename ':: If exogenous is a nested cell it has to have the same length ',...
                                     'as the number of dependent expressions (' int2str(nDep) ').'])
                end
                nDep     = length(options.dependent);
                exoFuncs = cell(1,nDep);
                vars     = cell(1,nDep);
                for ii = 1:nDep
                    nExoOne     = length(options.exogenous{ii});
                    exoFuncsOne = cell(1,nExoOne);
                    varsOne     = cell(1,nExoOne);
                    for jj = 1:nExoOne
                        [exoFuncsOne{jj},nLags,varsOne{jj}] = nb_exprEstimator.eqs2funcSub(options.dataVariables,options.exogenous{ii}{jj},false);
                        [maxLags,minLags,indContOne]        = updateLags(maxLags,minLags,nLags,varsOne{jj},depOrig);
                        indCont(ii,:)                       = indCont(ii,:) | indContOne;
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
    if options.recursive_estim
        
        % Shorten sample
        [options,yAll,XAll] = nb_estimator.testSample(options,[yEq{:}],[XEq{:}]);

        % Check the sample
        numCoeff                = max(nExo) + options.constant + options.time_trend;
        T                       = size(yAll,1);
        [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,numCoeff,T);
            
    else
        
        % Shorten sample
        [options,yAll,XAll] = nb_estimator.testSample(options,[yEq{:}],[XEq{:}]);

        % Check the degrees of freedom
        numCoeff = max(nExo) + options.constant + options.time_trend;
        T        = size(yAll,1);
        iter     = 1;
        start    = T;
        ss       = 1;
        nb_estimator.checkDOF(options,numCoeff,T);
        
    end
    
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
    
    % Check for constant regressors, which we do not allow
%     if any(all(diff(XAll,1) == 0,1))
%         error([mfilename ':: One or more of the selected exogenous variables is/are constant. '...
%                          'Use the constant option instead.'])
%     end
    
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
            res        = nan(T,1,iter);
            kk         = 1;
            for tt = start:T
                
                if options.removeZeroRegressors
                    ind  = ~all(abs(X(ss(kk):tt,:)) < eps,1);
                    indA = [true(1,nCoeff - size(X,2)), ind];
                else
                    ind  = true(1,size(X,2));
                    indA = true(1,nCoeff);
                end
                
                [beta(indA,:,kk),stdBeta(indA,:,kk),~,~,res(ss(kk):tt,:,kk)] = nb_ols(y(ss(kk):tt,:),X(ss(kk):tt,ind),constant,time_trend,stdType);
                kk = kk + 1;
                
            end
            
            % Get estimation results
            %--------------------------------------------------
            results.beta{ii}         = beta;
            results.stdBeta{ii}      = stdBeta;
            results.residual(:,ii,:) = res;

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
            
            [beta,stdBeta,tStatBeta,pValBeta,res,XX] = nb_ols(y,X(:,ind),options.constant,options.time_trend,options.stdType);

            if options.removeZeroRegressors
                nCoeff             = nExo(ii) + options.constant + options.time_trend;
                numEq              = size(y,2);
                indA               = [true(1,nCoeff - size(XRest,2)), ind];
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
            results.residual(:,ii)  = res;
            results.predicted(:,ii) = y - res;
            results.regressors{ii}  = XX;

            % Get aditional test results
            %--------------------------------------------------
            if options.doTests
                results.tests{ii} = nb_olsEstimator.doTest(results.tests{ii},options,beta,y,X,res);
            end

        end
        
        results.includedObservations(ii) = size(y,1);
        
    end
    
    % Estimate the covariance matrix
    %--------------------------------
    sigma = nan(nDep,nDep,iter);
    kk    = 1;
    for tt = start:T
        resid         = results.residual(ss(kk):tt,:,kk);
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

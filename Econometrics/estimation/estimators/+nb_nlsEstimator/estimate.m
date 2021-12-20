function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_nlsEstimator.estimate(options)
%
% Description:
%
% Estimate a model with nls.
% 
% Input:
% 
% - options  : A struct on the format given by nb_nlsEstimator.template.
%              See also nb_nlsEstimator.help.
% 
% Output:
% 
% - result  : A struct with the estimation results.
%
% - options : The return model options, can change.
%
% See also:
% nb_nlsEstimator.print, nb_nlsEstimator.help, nb_nlsEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end
    options = nb_defaultField(options,'class','');
    options = nb_defaultField(options,'requiredDegreeOfFreedom',3);

    % Get the estimation options
    %------------------------------------------------------
    tempDep = cellstr(options.parser.dependent);
    if isempty(tempDep)
        error([mfilename ':: No dependent variables selected, please assign the dependent field of the options property.'])
    end
    if isempty(options.data)
        error([mfilename ':: Cannot estimate without data.'])
    end

    % Get the estimation data
    %------------------------------------------------------
    if isempty(options.estim_types) % Time-series

        % Add lags
        looped       = [options.parser.dependent,options.parser.exogenous];
        [testS,indS] = ismember(looped,options.dataVariables);
        if any(~testS)
            error([mfilename ':: Some of the variables of the model are not found to be in the dataset; ' toString(options.parser.variables(~testS))])
        end
        options.data          = [options.data, nb_slag(options.data(:,indS),options.parser.lags)];
        options.dataVariables = [options.dataVariables, nb_scellstrlag(looped,options.parser.lags)];
        
        % Get data
        [~,indV] = ismember(options.parser.variables,options.dataVariables);
        X        = options.data(:,indV);
        if isempty(X)
            error([mfilename ':: The selected sample cannot be empty.'])
        end
        
    else

        % Get data as a double
        [testV,indV] = ismember(options.parser.variables,options.dataVariables);
        [testT,indT] = ismember(options.estim_types,options.dataTypes);
        if any(~testV)
            error([mfilename ':: Some of the dependent variable are not found to be in the dataset; ' toString(options.parser.variables(~testV))])
        end
        if any(~testT)
            error([mfilename ':: Some of the types are not found to be in the dataset; ' toString(options.estim_types(~testT))])
        end
        X = options.data(indT,indV);
        if isempty(X)
            error([mfilename ':: The number of selected types cannot be 0.'])
        end

    end
    
    % Get actual
    [~,indY] = ismember(options.parser.dependent,options.dataVariables);
    y        = options.data(:,indY);
    
    % Do the estimation
    %------------------------------------------------------
    % Optimizer options
    opt = nb_getDefaultOptimset(options.optimset,options.optimizer);
    if isempty(opt.OutputFcn)
        opt.Display = 'iter';
    end
    
    % Initial conditions
    init = zeros(length(options.parameters),1);
    if ~nb_isempty(options.init)
        fields = fieldnames(options.init);
        for ii = 1:length(fields)
            ind = strcmp(fields{ii},options.parameters);
            if any(ind)
                init(ind) = options.init.(fields{ii});
            else
                error([mfilename ':: ' fields{ii} ' is not a parameter of the model, but it given as a field of the ''init'' option.'])
            end
        end
    end
    
    % Get lower bound
    lb = -inf(length(options.parameters),1);
    if ~nb_isempty(options.lb)
        fields = fieldnames(options.lb);
        for ii = 1:length(fields)
            ind = strcmp(fields{ii},options.parameters);
            if any(ind)
                lb(ind) = options.lb.(fields{ii});
            else
                error([mfilename ':: ' fields{ii} ' is not a parameter of the model, but it given as a field of the ''lb'' option.'])
            end
        end
    end
    
    % Initial conditions
    ub = inf(length(options.parameters),1);
    if ~nb_isempty(options.ub)
        fields = fieldnames(options.ub);
        for ii = 1:length(fields)
            ind = strcmp(fields{ii},options.parameters);
            if any(ind)
                ub(ind) = options.ub.(fields{ii});
            else
                error([mfilename ':: ' fields{ii} ' is not a parameter of the model, but it given as a field of the ''ub'' option.'])
            end
        end
    end
        
    % Check for constant regressors, which we do not allow
    if any(all(diff(X,1) == 0,1))
        error([mfilename ':: One or more of the selected exogenous variables is/are constant.'])
    end

    % Get constraints as function handle
    constrFunc = nb_model_parse.constraints2func(options.parser);
    
    if options.recursive_estim

        if ~isempty(options.estim_types)
            error([mfilename ':: Recursive estimation is only supported for time-series.'])
        end
        
        % Shorten sample
        [options,y,X] = nb_estimator.testSample(options,y,X);

        % Check the sample
        numCoeff                = length(options.parameters);
        T                       = size(X,1);
        [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,numCoeff,T);
            
        % Estimate the model recursively
        %--------------------------------------------------
        numEq      = length(options.parser.equations);
        beta       = nan(numCoeff,numEq,iter);
        stdBeta    = nan(numCoeff,numEq,iter);
        residual   = nan(T,numEq,iter);
        covrepair  = options.covrepair;
        optimizer  = options.optimizer;
        func       = options.parser.eqFunc;
        constrFunc = options.constrFunc;
        kk         = 1;
        vcv        = nan(numEq,numEq,iter);
        for tt = start:T
            [message,beta(:,:,kk),stdBeta(:,:,kk),~,~,residual] = nb_nls(init,ub,lb,opt,optimizer,covrepair,func,y(ss(kk):tt,:),X(ss(kk):tt,:),false,'NONLCON',constrFunc);
            if ~isempty(message)
                date = nb_date.date2freq(options.dataStartDate) + (tt - 1);
                error([message ' Error occurred at recursive iteration number ' int2str(tt) ' (' toString(date) ').'])
            end
            kk = kk + 1; 
            init = beta(:,:,kk);
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
            numCoeff = length(options.parameters);
            T        = size(X,1);
            nb_estimator.checkDOF(options,numCoeff,T);

        else
            
            numCoeff = length(options.parameters);
            N        = size(X,1);
            nb_estimator.checkDOF(options,numCoeff,N);
            
            % Secure that the data is balanced
            %------------------------------------------------------
            if any(isnan(X(:)))
                error([mfilename ':: The estimation data is not balanced.'])
            end
             
        end

        % Estimate model by nls
        %--------------------------------------------------
        covrepair  = options.covrepair;
        optimizer  = options.optimizer;
        func       = options.parser.eqFunc;
        [message,beta,stdBeta,tStatBeta,pValBeta,residual] = nb_nls(init,ub,lb,opt,optimizer,covrepair,func,y,X,false,'NONLCON',constrFunc);
        if ~isempty(message)
            error(message)
        end
        
        % Estimate the covariance matrix
        %-------------------------------
        T     = size(residual,1);
        sigma = residual'*residual/(T - numCoeff);
        
        % Get estimation results
        %--------------------------------------------------
        res            = struct();
        res.beta       = beta;
        res.stdBeta    = stdBeta;
        res.tStatBeta  = tStatBeta;
        res.pValBeta   = pValBeta;
        res.residual   = residual;
        res.sigma      = sigma;
        res.predicted  = y - residual;
       
        % Get aditional test results
        %--------------------------------------------------
        if options.doTests
            res = nb_nlsEstimator.doTest(res,options,residual);
        end
        
    end

    % Assign generic results
    res.includedObservations = size(X,1);
    res.elapsedTime          = toc(tStart);
    
    % Assign results
    results           = res;
    options.estimator = 'nb_nlsEstimator';
    options.estimType = 'classic';

end


function obj = doTest(obj)
% Syntax:
%
% obj = doTest(obj)
%
% Description:
%
% Do f-test. Results are stored in the property results.
% 
% Input:
% 
% - obj : An object of class nb_fTestStatistics, where the 
%         restrictions to test is stored in options.A and 
%         options.c. (A*beta = c)
% 
% Output:
% 
% - obj : An object of class nb_fTestStatistics.
%
% Written by Kenneth Sæterhagen Paulsen
            
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the estimation results
    if isa(obj.model,'nb_model_generic')
        mResults  = obj.model.results;
        mOpt      = obj.model.estOptions;
    else
        error([mfilename ':: F-test can only be done on a object which is of a subclass of nb_model_generic'])
    end
    opt = obj.options;
    
    % Get the needed inputs from the wanted equation
    if strcmpi(mOpt.estimator,'nb_tslsEstimator')
        mResults = mResults.mainEq;
        mOpt     = mOpt.mainEq;
        numExo   = size(mOpt.exogenous,2) + size(mOpt.endogenous,2) + mOpt.constant + mOpt.time_trend;
    else
        numExo = size(mOpt.exogenous,2) + mOpt.constant + mOpt.time_trend;
    end
    
    % Check inputs
    if isempty(opt.dependent)
       obj.options.dependent = mOpt.dependent{1}; 
       ind = 1;
    else
       ind = strcmpi(opt.dependent,mOpt.dependent);
    end
    
    beta     = mResults.beta;
    beta     = beta(:,ind);
    residual = mResults.residual;
    residual = residual(:,ind);
    X        = mResults.regressors;
    
    if strcmpi(mOpt.estimator,'nb_olsEstimator') || strcmpi(mOpt.estimator,'nb_tslsEstimator')
        
        % If equations are estimated in one step we need to get 
        % the regressors of the one equation we are testing
        T       = size(residual,1);    
        varInd  = (ind - 1)*numExo + 1:numExo*ind;
        dim1Ind = (ind - 1)*T + 1:T*ind;
        X       = X(dim1Ind,varInd);
        
    else
        error([mfilename ':: The F-test is only supported for the estimators nb_olsEstimator and nb_tslsEstimator.'])
    end

    if isempty(opt.A)
        error([mfilename ':: The options.A field cannot be empty. Add the restriction to test to this field.'])
    elseif size(opt.A,2) ~= size(beta,1)
        error([mfilename ':: The size(options.A,2) must equal the number of estimated coefficients (' int2str(size(beta,1)) ').'])
    end

    if isempty(opt.c)
        error([mfilename ':: The options.c field cannot be empty. Add the restriction to test to this field.'])
    elseif size(opt.c,2) ~= size(beta,2)
        error([mfilename ':: The size(options.c,2) must equal the number of estimated equations (' int2str(size(beta,2)) ').'])
    end

    % Do the test
    [fTest,fProb] = nb_restrictedFTest(opt.A,opt.c,X,beta,residual);

    % Report results
    res         = struct('fTest',fTest,'fProb',fProb);
    obj.results = res;

end

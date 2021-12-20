function obj = doTest(obj)
% Syntax:
%
% obj = doTest(obj)
%
% Description:
%
% Do Breusch-Godfrey autocorrelation test. Results are stored in the property 
% results.
% 
% Input:
% 
% - obj : An object of class nb_breuschGodfreyTestStatistic.
% 
% Output:
% 
% - obj : An object of class nb_breuschGodfreyTestStatistic.
%
% Written by Kenneth Sæterhagen Paulsen
            
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the estimation results
    if isa(obj.model,'nb_model_generic')
        mResults  = obj.model.results;
        mOpt      = obj.model.estOptions;
    else
        error([mfilename ':: Breusch-Godfrey autocorrelation test can only be done on an object which is of a subclass of nb_model_generic'])
    end
    if strcmpi(mOpt.estimator,'nb_tslsEstimator')
        mResults = mResults.mainEq;
        mOpt     = mOpt.mainEq;
    end
    opt = obj.options;
    
    % Check nLags input
    %--------------------------------------------------------------
    lags = opt.nLags;
    if ~isnumeric(lags) || ~isscalar(lags)
        error([mfilename ':: The nLags option must be a 1x1 double.'])
    end
    if lags < 1
        error([mfilename ':: The nLags option must be a number greater than 0.'])
    end
    lags = round(lags);

    % Get statistics
    residual = mResults.residual;
    T        = size(residual,1);
    numCoeff = size(mResults.beta,1);
    X        = mResults.regressors(1:T,1:numCoeff);
    if mOpt.constant % Remove constant
       X = X(:,2:end); 
    end
    [test,prob] = nb_breuschGodfreyTest(residual,X,lags);
    
    % Report results
    res = struct('test',        test,...
                 'prob',        prob,...
                 'dependent',   {mOpt.dependent});
    obj.results = res;

end

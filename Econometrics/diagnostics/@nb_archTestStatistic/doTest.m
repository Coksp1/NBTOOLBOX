function obj = doTest(obj)
% Syntax:
%
% obj = doTest(obj)
%
% Description:
%
% Do ARCH-test. Results are stored in the property results.
% 
% Input:
% 
% - obj : An object of class nb_archTestStatistic.
% 
% Output:
% 
% - obj : An object of class nb_archTestStatistic.
%
% Written by Kenneth Sæterhagen Paulsen
            
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the estimation results
    if isa(obj.model,'nb_model_generic')
        mResults  = obj.model.results;
        mOpt      = obj.model.estOptions;
    else
        error([mfilename ':: ARCH-test can only be done on a object which is of a subclass of nb_model_generic'])
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
    residual            = mResults.residual;
    [archTest,archProb] = nb_archTest(residual,lags);
    
    % Report results
    dep = mOpt.dependent;
    if isfield(mOpt,'block_exogenous')
        dep = [dep,mOpt.block_exogenous];
    end
    res = struct('archTest',    archTest,...
                 'archProb',    archProb,...
                 'dependent',   {dep});
    obj.results = res;

end

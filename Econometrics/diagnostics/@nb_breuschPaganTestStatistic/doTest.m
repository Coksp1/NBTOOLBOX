function obj = doTest(obj)
% Syntax:
%
% obj = doTest(obj)
%
% Description:
%
% Do Breusch-Pagan heteroscedasticity test. Results are stored in the  
% property results.
% 
% Input:
% 
% - obj : An object of class nb_breuschPaganTestStatistic.
% 
% Output:
% 
% - obj : An object of class nb_breuschPaganTestStatistic.
%
% Written by Kenneth Sæterhagen Paulsen
            
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the estimation results
    if isa(obj.model,'nb_model_generic')
        mResults  = obj.model.results;
        mOpt      = obj.model.estOptions;
    else
        error([mfilename ':: Breusch-Pagan heteroscedasticity test can only be done on an object which is of a subclass of nb_model_generic'])
    end
    if strcmpi(mOpt.estimator,'nb_tslsEstimator')
        mResults = mResults.mainEq;
        mOpt     = mOpt.mainEq;
    end
    
    % Check nLags input
    %--------------------------------------------------------------

    % Get statistics
    residual = mResults.residual;
    T        = size(residual,1);
    numCoeff = size(mResults.beta,1);
    X        = mResults.regressors(1:T,1:numCoeff);
    if mOpt.constant % Remove constant
       X = X(:,2:end); 
    end
    [test,prob] = nb_breuschPaganTest(residual,X);
    
    % Report results
    res = struct('test',        test,...
                 'prob',        prob,...
                 'dependent',   {mOpt.dependent});
    obj.results = res;

end

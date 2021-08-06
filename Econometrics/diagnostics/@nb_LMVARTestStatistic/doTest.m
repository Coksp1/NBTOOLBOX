function obj = doTest(obj)
% Syntax:
%
% obj = doTest(obj)
%
% Description:
%
% Do LM test for autocorrelated residuals. Results are stored in the 
% property results.
% 
% Input:
% 
% - obj : An object of class nb_LMVARTestStatistic.
% 
% Output:
% 
% - obj : An object of class nb_LMVARTestStatistic.
%
% Written by Kenneth Sæterhagen Paulsen
            
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the estimation results
    if isa(obj.model,'nb_model_generic')
        mResults = obj.model.results;
        mOpt     = obj.model.estOptions;
    else
        error([mfilename ':: F-test can only be done on an object which is of a subclass of nb_model_generic'])
    end
    
    % Get statistics
    residual        = mResults.residual;
    T               = size(residual,1);
    k               = obj.options.lag; % The number of lags of the VAR
    numCoeff        = size(mResults.beta,1);
    X               = mResults.regressors(1:T,1:numCoeff);
    if mOpt.constant % Remove constant
       X = X(:,2:end); 
    end
    [stat,prob] = nb_LMVARTest(residual,X,k);
    
    % Report results
    res = struct('LMVARTest', stat,...
                 'LMVARProb', prob);
    obj.results = res;

end

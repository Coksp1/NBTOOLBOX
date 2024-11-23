function obj = doTest(obj)
% Syntax:
%
% obj = doTest(obj)
%
% Description:
%
% Do Ljung-Box test. Results are stored in the property results.
% 
% Input:
% 
% - obj : An object of class nb_ljungBoxTestStatistic.
% 
% Output:
% 
% - obj : An object of class nb_ljungBoxTestStatistic.
%
% Written by Kenneth Sæterhagen Paulsen
            
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the estimation results
    if isa(obj.model,'nb_model_generic')
        mResults = obj.model.results;
        mOpt     = obj.model.estOptions;
    else
        error([mfilename ':: F-test can only be done on an object which is of a subclass of nb_model_generic'])
    end
    
    % Get statistics
    residual        = mResults.residual;
    p               = mOpt.nLags + 1; % The number of lags of the VAR
    [lbTest,lbProb] = nb_ljungBoxTest(residual,p,obj.options.nLags,...
        obj.options.type);
    
    % Report results
    dep = mOpt.dependent;
    if isfield(mOpt,'block_exogenous')
        dep = [dep,mOpt.block_exogenous];
    end
    res = struct('ljungBoxTest', lbTest,...
                 'ljungBoxProb', lbProb,...
                 'dependent',    {dep});
    obj.results = res;

end

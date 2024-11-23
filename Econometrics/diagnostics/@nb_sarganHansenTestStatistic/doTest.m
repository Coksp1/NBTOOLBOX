function obj = doTest(obj)
% Syntax:
%
% obj = doTest(obj)
%
% Description:
%
% Do Sargan-Hansen test. Results are stored in the property results.
% 
% Input:
% 
% - obj : An object of class nb_sarganHansenTestStatistic.
% 
% Output:
% 
% - obj : An object of class nb_sarganHansenTestStatistic.
%
% Written by Kenneth Sæterhagen Paulsen
            
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the estimation results
    if isa(obj.model,'nb_model_generic')
        mResults = obj.model.results;
        mOpt     = obj.model.options;
    else
        error([mfilename ':: Sargan-Hansen test can only be done on an object which is of a subclass of nb_model_generic'])
    end
    
    if ~strcmpi(obj.model.estOptions.estimator,'nb_tslsEstimator')
        error('This test is only valid for the TSLS estimator. (nb_tslsEstimator)')
    end
    
    % Get the data
    tempEndo      = obj.model.endogenous.name;
    tempExo       = obj.model.exogenous.name;
    tempInstr     = obj.model.options.instruments(2:2:end);
    tempInstr_    = [tempInstr{:}];
    tempAll       = unique([tempExo,tempInstr_]);
    tempData      = double(mOpt.data);
    dataVariables = mOpt.data.variables;
    [~,indX]      = ismember(tempAll,dataVariables);
    inst          = tempData(:,indX);
    
    if isfield(mOpt,'time_trend')
        timeTrend = mOpt.time_trend;
    else
        timeTrend = 0;
    end
    
    % Find the number of overidentifying restrictions
    overident = 0;
    nEndo     = length(tempInstr);
    for ii = 1:nEndo
    
        ind = ismember(tempInstr{ii},tempExo);
        o_q = sum(~ind);
        if o_q < 2
            error([mfilename ':: The model is not overidentified. The endogenous variable '  tempEndo{ii} ' has only been given one '...
                             'instrument not included as an exogenous variable in the main equation.'])
        end
        overident = overident + o_q;
        
    end
        
    % Get statistics
    residual    = mResults.('mainEq').residual;
    [test,prob] = nb_sarganHansen(residual,nan(size(inst,1),0),inst,overident,mOpt.constant,timeTrend);
    
    % Report results
    res = struct('test',      test,...
                 'prob',      prob,...
                 'dependent', {obj.model.dependent.name});
    obj.results = res;

end

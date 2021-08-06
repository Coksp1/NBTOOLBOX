function obj = doTest(obj)
% Syntax:
%
% obj = doTest(obj)
%
% Description:
%
% Do the Durbin-Wu-Hausman test. Results are stored in the property 
% results.
% 
% Input:
% 
% - obj : An object of class nb_durbinWuHausmanStatistic. See template
%         for the options of the test.
% 
% Output:
% 
% - obj : An object of class nb_durbinWuHausmanStatistic.
%
% Written by Kenneth Sæterhagen Paulsen
            
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the estimation results
    if isa(obj.model,'nb_singleEq')
        mOpt = obj.model.estOptions;
    else
        error([mfilename ':: Durbin-Wu-Hausman test can only be done on an object of class nb_singleEq'])
    end

    % Get the needed inputs from the wanted equation
    if strcmpi(mOpt.estimator,'nb_tslsEstimator')
        tempDep              = obj.model.dependent.name;
        tempExo              = obj.model.exogenous.name;
        tempEndo             = obj.model.endogenous.name;
        tempInstr            = obj.model.options.instruments(2:2:end);
        mOpt.data            = double(obj.model.options.data);
        mOpt.dataVariables   = obj.model.options.data.variables;
        mOpt.constant        = obj.model.options.constant;
        mOpt.time_trend      = obj.model.options.time_trend;
        mOpt.dependent       = tempDep;
        mOpt.estim_start_ind = mOpt.firstStageEq1.estim_start_ind;
        mOpt.estim_end_ind   = mOpt.firstStageEq1.estim_end_ind;
    else
        tempDep   = mOpt.dependent;
        tempExo   = mOpt.exogenous;
        tempEndo  = obj.options.endogenous;
        ind       = ismember(tempExo,tempEndo);
        tempExo   = tempExo(~ind);
        tempInstr = obj.options.instruments;
    end
    
    % Test input
    numZ     = length(tempEndo);
    numInstr = length(tempInstr);
    if numZ ~= numInstr
        error(['The number of endogenous variables (' int2str(numZ) ') must match the selected instruments (' int2str(numInstr) ').'])
    end
    
    % Get the data
    indT     = mOpt.estim_start_ind:mOpt.estim_end_ind;
    tempData = mOpt.data;
    [~,indY] = ismember(tempDep,mOpt.dataVariables);
    y        = tempData(indT,indY);
    [~,indX] = ismember(tempExo,mOpt.dataVariables);
    x        = tempData(indT,indX);
    [~,indZ] = ismember(tempEndo,mOpt.dataVariables);
    z        = tempData(indT,indZ);
    inst     = cell(1,numInstr);
    for ii = 1:numInstr
        [~,indI] = ismember(tempInstr{ii},mOpt.dataVariables);
        inst{ii} = tempData(indT,indI);
    end
    
    if isfield(mOpt,'time_trend')
        timeTrend = mOpt.time_trend;
    else
        timeTrend = 0;
    end
    
    % Do the test
    [test,prob] = nb_durbinWuHausman(y,x,z,inst,mOpt.constant,timeTrend);

    % Report results
    obj.results = struct('test',test,'prob',prob,...
                         'dependent',   {mOpt.dependent});

end

function momentsCallback(gui,~,~)
% Syntax:
%
% momentsCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Calculate covarince matrix used by the copula.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the endogenous variables to condition on
    endo     = gui.model.solution.endo;
    ind      = ismember(gui.variables,endo);
    endoRest = gui.variables(ind);
    if isempty(endoRest)
        nb_errorWindow(['No endogenous variables are conditioned on, so there are no need to '...
                       'calculate the correlation matrix used by the copula.'])
        return
    end
    endoRest = [gui.restrictedVariables,endoRest];

    % Find the correlation matrix to use.
    %nLags               = nb_getUIControlValue(gui.lagsOption, 'numeric');
    initPeriods         = nb_getUIControlValue(gui.initPeriodsOption, 'numeric');
    nSteps              = length(gui.dates);
    method              = nb_getSelectedFromPop(gui.covarianceOption);
    [gui.sigma,retcode] = nb_selectConditionalDistributionsGUI.constructSigma(gui.model,nSteps,initPeriods,endoRest,method);
    if retcode
        return
    end
    
    if gui.initPeriods > 0
        gui.distributions = gui.distributions(gui.initPeriods + 1:end,:);
        gui.dates         = gui.dates(gui.initPeriods + 1:end);
    end
    
    if initPeriods > 0 && ~isempty(endoRest)
        initDistr            = nb_distribution('type','constant','parameters',{nan});
        initDistr            = initDistr(ones(1,initPeriods),ones(1,size(gui.distributions,2)));
        [~,indEndo]          = ismember(endoRest,gui.variables);
        histDBEndo           = getHistory(gui.model,endoRest);
        histDBEndo           = window(histDBEndo,histDBEndo.endDate - initPeriods + 1);
        initDistr(:,indEndo) = nb_distribution.double2Dist(histDBEndo.data);
        gui.distributions    = [initDistr;gui.distributions];
        extra                = histDBEndo.endDate - initPeriods + 1:histDBEndo.endDate;
        gui.dates            = [extra;gui.dates];
    end
    
    % Update the table with the covariance matrix
    set(gui.tableHandle2, ...
        'ColumnName',   gui.sigma.variables, ...
        'RowName',      gui.sigma.types, ...
        'Data',         gui.sigma.data);
    
    if gui.initPeriods > 0 || initPeriods > 0
        gui.addToHistory();
        gui.updateGUI();
    end
    gui.initPeriods = initPeriods;
    
end


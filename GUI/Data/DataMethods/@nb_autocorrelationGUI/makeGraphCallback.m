function makeGraphCallback(gui,~,~)
% Syntax:
%
% makeGraphCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Check input and create output as graphs in a new window.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get inputs
    nLags       = str2double(get(gui.nLagsBox,'string'));
    alpha       = str2double(get(gui.alfaBox,'string'));
    index       = get(gui.methodBox,'value');
    string      = get(gui.methodBox,'string');
    errorBound	= string{index};
    index       = get(gui.typeBox,'value');
    string      = get(gui.typeBox,'string');
    type        = string{index};
    maxMA       = str2double(get(gui.maxMABox,'string'));
    index       = get(gui.algorithmBox,'value');
    string      = get(gui.algorithmBox,'string');
    algorithm   = string{index};
    maxAR       = str2double(get(gui.maxARBox,'string'));
    index       = get(gui.criteriaBox,'value');
    string      = get(gui.criteriaBox,'string');
    criteria    = string{index};
    index       = get(gui.startDateBox,'value');
    string      = get(gui.startDateBox,'string');
    startD      = string{index};
    index       = get(gui.endDateBox,'value');
    string      = get(gui.endDateBox,'string');
    endD        = string{index};
    index       = get(gui.variableBox,'value');
    string      = get(gui.variableBox,'string');
    vars        = string(index);
    if strcmpi(vars{1},'all')
        
        if strcmpi(errorBound,'parametric bootstrap') && strcmpi(algorithm,'Maximum Likelihood')
            nb_errorWindow(['To select parametric bootstrap and maximum likelihood estimation is not possible '...
                            'in combination with selecting all variables.'])
            return
        end
        vars = gui.data.variables;
    end
    
    % Check numeric inputs
    if ~isnan(nLags)
        if nLags < 0
            nb_errorWindow('Number of lags cannot be negative')
            return
        end
    else
        nb_errorWindow('Number of lags must be numeric');
        return
    end
    
    if ~isnan(alpha)
        if alpha < 0 || alpha > 1
            nb_errorWindow('Alpha value cannot be negative or greater than one.')
            return
        end
    else
        nb_errorWindow('Alpha value must be numeric');
        return
    end
    
    if strcmpi(errorBound,'parametric bootstrap')
    
        if ~isnan(maxAR)
            if maxAR < 0
                nb_errorWindow('MaxAR value must be greater than zero');
                return
            end
        else
            nb_errorWindow('MaxAR value must be numeric');
            return
        end

        if ~isnan(maxMA)
            if maxMA < 0
                nb_errorWindow('MaxMA value must be greater than zero');
                return
            end
        else
            nb_errorWindow('MaxMA value must be numeric');
            return
        end

        % Transform method and criteria to the correct format
        switch algorithm
            case 'Maximum Likelihood'
                method = 'ml';
            case 'Hannan-Rissanen'
                method = 'hr';
        end
        
        switch criteria
            case 'Akaike information criterion'
                criterion = 'aic';
            case 'Corrected Akaike information criterion'
                criterion = 'aicc';
            case 'Modified Akaike information criterion'
                criterion = 'maic';
            case 'Schwarz information criterion'
                criterion = 'sic';
            case 'Modified Schwarz information criterion'
                criterion = 'msic';
            case 'Hannan and Quinn information criterion'
                criterion = 'hqc';
            case 'Modified Hannan and Quinn information criterion' 
                criterion = 'mhqc';

        end
        
    else
        maxAR     = [];
        maxMA     = [];
        method    = '';
        criterion = '';
    end
    
    if strcmpi(errorBound,'parametric bootstrap')
        errorBound = 'parambootstrap';
    elseif strcmpi(errorBound,'block bootstrap')
        errorBound = 'blockbootstrap';
    elseif strcmpi(errorBound,'random length block bootstrap')
        errorBound = 'rblockbootstrap';
    elseif strcmpi(errorBound,'wild block bootstrap')
        errorBound = 'wildblockbootstrap';
    elseif strcmpi(errorBound,'wild bootstrap')
        errorBound = 'wildbootstrap';
    elseif strcmpi(errorBound,'copula bootstrap')
        errorBound = 'copulabootstrap';
    end
        
    % Get the sample
    dataT = window(gui.data,startD,endD,vars);
    if isempty(dataT)
        nb_errorWindow('With the selected start and end date the sample is empty.')
        return
    elseif dataT.numberOfObservations < 10
        nb_errorWindow('With the selected start and end date the sample is to short. Must at least have 10 periods.')
        return
    end
    
    % Check for nan values
    nanValues = isnan(dataT.data);
    if  any(nanValues(:)) 
        nb_errorWindow('Cannot perform this test on unbalanced data (The selected sample has nan values)');
        return
    end
    
    % Perform estimation
    switch lower(type)
        case 'sample autocorrelation'
            try
                statData = autocorr(dataT,nLags,errorBound,alpha,'maxAR',maxAR,...
                    'maxMA',maxMA,'method',method,'criterion',criterion);
            catch Err
               nb_errorWindow('Too few observations.', Err) 
               return
            end
        case 'partial autocorrelation'
            try
                statData = parcorr(dataT,nLags,errorBound,alpha,'maxAR',maxAR,...
                    'maxMA',maxMA,'method',algorithm,'criterion',criterion);
            catch Err
               nb_errorWindow('Too few observations.', Err) 
               return
            end
    end
    
    % Make the graphs
    
    if length(vars) > 1
        
        plotter = nb_graph_data(statData);
        if nLags > 1 
           markers = {};
        else
           markers = {statData.dataNames{1},'',statData.dataNames{2}, 'square',statData.dataNames{3}, 'square'};
        end
        plotter.set('lineWidth',2,...
                    'plotTypes',   {statData.dataNames{1},'grouped'},...
                    'markers',     markers,...
                    'colororder',  {'sky blue','purple','purple'});
        
        nb_graphSubPlotGUI(plotter,gui.parent);
    else
        
        statData = squeeze(statData);
        plotter  = nb_graph_data(statData);
        if nLags > 1 
           markers = {};
        else
           markers = {statData.variables{1},'',statData.variables{2}, 'square',statData.variables{3}, 'square'};
        end
        plotter.set('lineWidth',   2,...
                    'plotTypes',   {statData.variables{1},'grouped'},...
                    'markers',     markers,...
                    'colors',      {statData.variables{1},'sky blue',statData.variables{2},'purple',statData.variables{3},'purple'},...
                    'legends',     {'Autocorrelations','Error bound (lower)','Error bound (upper)'});
        
        nb_graph_dataGUI(gui.parent,'normal',plotter);
    end
    
end


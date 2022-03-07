function okCallback(gui,~,~)
% Syntax:
%
% okCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Executes test and opens the results in a new window
% 
% Written by Eyo Herstad

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get seasonal choice
    %---------------------------------------------------------------
    index = get(gui.optionPanelComponents.seasonalBox,'value');
    string = get(gui.optionPanelComponents.seasonalBox,'string');
    seasonal = string{index};
   
    % Get model choice
    %--------------------------------------------------------------  
    % Get deterministic assumptions
    if get(gui.determPanelComponents.btn1,'value')
        model = 'H2';
    else
        if get(gui.determPanelComponents.btn2,'value')
            model = 'H1*';
            
        else
            if get(gui.determPanelComponents.btn3,'value')
                model = 'H1';
                
            else
                if get(gui.determPanelComponents.btn4,'value')
                    model = 'H*';
                    
                else
                    if get(gui.determPanelComponents.btn5,'value')
                        model = 'h';
                        
                    else
                        nb_errorWindow('Something is broken');
                        return
                    end
                end
            end
        end
    end
    
    % Get test value for hypothesis
    ind     = get(gui.optionPanelComponents.testBox,'value');
    string  = get(gui.optionPanelComponents.testBox,'string');
    hypo    = string{ind};
    
    if strcmp(hypo,'Max Eigenvalue')
        hypo = 'maxeig';
        
    end
    
    % Get lag options
    %--------------------------------------------------------------
    % Get lag length selections
    lagSelect     = get(gui.lagPanelComponents.autSelectBtn,'value');
    string        = get(gui.lagPanelComponents.criterionBox,'string');
    index         = get(gui.lagPanelComponents.criterionBox,'value');
    criterion     = string{index};
    maxLagSelect  = get(gui.lagPanelComponents.maxLagLengthBox,'string');
    maxLagSelect  = str2double(maxLagSelect);
    userLagSelect = get(gui.lagPanelComponents.userLagSelect,'string');
    userLagSelect = str2double(userLagSelect);
    
    % Set the criterion input format
    switch criterion
        case 'Akaike information criterion'
            lagLengthCrit = 'aic';
        case 'Modified Akaike information criterion'
            lagLengthCrit = 'maic';
        case 'Schwarz information criterion'
            lagLengthCrit = 'sic';
        case 'Modified Schwarz information criterion'
            lagLengthCrit = 'msic';
        case 'Hannan-Quinn information criterion'
            lagLengthCrit = 'hqc';
        case 'Modified Hannan-Quinn information criterion'
            lagLengthCrit = 'mhqc';
    end
    
    % Shorten the sample
    %-----------------------------------------------------------
    string    = get(gui.optionPanelComponents.startDate,'string');
    value     = get(gui.optionPanelComponents.startDate,'value');
    startDate = string{value};
    string    = get(gui.optionPanelComponents.endDate,'string');
    value     = get(gui.optionPanelComponents.endDate,'value');
    endDate   = string{value};
    string    = get(gui.varSelPanelComponents.varSelListBox,'string');
    value     = get(gui.varSelPanelComponents.varSelListBox,'value');
    vars      = string(value);
    if length(vars) == 1
        nb_errorWindow('At least two variables must be selected!')
        return
    end
    
    dataT = window(gui.data,startDate,endDate,vars);
    if isempty(dataT)
        nb_errorWindow('The selected start date is after the selected end date')
        return
    end
    
    % User set lag length
    %-----------------------
    if lagSelect ~= 1 
        
        nLags         = round(userLagSelect);
        maxLags       = 11;
        lagLengthCrit = '';
        
        if isnan(nLags)
            nb_errorWindow('The lag length selection is not a number.')
            return
        elseif nLags < 0
            nb_errorWindow('The lag length selection is not a number greater than 0.')
            return
        end
        
    else % Automatic lag length
        nLags   = 2;
        maxLags = round(maxLagSelect);
        
        if isnan(maxLags)
            nb_errorWindow('The selected maximum lag length is not a number.')
            return
        elseif maxLags < 0
            nb_errorWindow('The selected maximum lag length is not a number greater than 0.')
            return
        end
        
        if maxLags > dataT.numberOfObservations-10
            maxLags = dataT.numberOfObservations-10;
        end
    end
    
    % Check for nan values
    %------------------------
    nanValues = isnan(dataT.data);
    if  any(nanValues(:)) 
        nb_errorWindow('Cannot do cointegration test on unbalanced datasets (has nan values)');
        return
    end
    
    % Do the test
    %--------------------------------------------------------------
    try
        temp = nb_cointTest(dataT,'jo',...
            'nLags',            nLags,...
            'maxLags',          maxLags-1,...
            'lagLengthCrit',    lagLengthCrit,...
            'model',            model,...
            'hypo',             hypo);
        
    catch Err
        
        nb_errorWindow('Cointegration test failed. MATLAB error: ', Err);
        return
    end

    % Create new window with results
    %--------------------------------------------------------------
    results           = print(temp);
    name              = [gui.parent.guiName ': Johansen Cointegration Test'];
    nb_printResults(results, name);

end


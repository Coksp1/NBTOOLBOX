function okCallback(gui,~,~)
% Syntax:
%
% okCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Executes test and opens the results in a new window.
% 
% Written by Eyo Herstad

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get test type
    %--------------------------------------------------------------
    index = get(gui.testTypeBox,'value');
    string = get(gui.testTypeBox,'string');
    testType = string{index};

    switch testType 
        case 'Augmented Dickey-Fuller'

            test = 'adf';

        case 'Phillips-Perron'

%             test = 'pp';
            nb_errorWindow('Phillips-Perron test for cointegration tests is not yet supported.')
            return
        case 'Kwiatkowski-Phillips-Schmidt-Shin'

%             test = 'kpss';
            nb_errorWindow('Kwiatkowski-Phillips-Schmidt-Shin test for cointegration tests is not yet supported.')
            return

    end

    
    % Get choice of dependendt variable
    %--------------------------------------------------------------
    index = get(gui.optionPanelComponents.dependentBox,'value');
    string = get(gui.optionPanelComponents.dependentBox,'string');
    dependent = string{index};
    
    % Get seasonal choice
    %---------------------------------------------------------------
    index = get(gui.optionPanelComponents.seasonalBox,'value');
    string = get(gui.optionPanelComponents.seasonalBox,'string');
    seasonal = string{index};
    
    % Get transformation of test data
    %--------------------------------------------------------------
    diff1Btn = gui.levelPanelComponents.diff1Btn;
    diff2Btn = gui.levelPanelComponents.diff2Btn;
    if get(diff2Btn,'value') ~= 1
        if get(diff1Btn,'value')~= 1
            transformation = 'level';
        else
            transformation = 'firstDiff';
        end
    else
        transformation = 'secondDiff';
    end

    % Get model choice
    %--------------------------------------------------------------
    trendIntercept = get(gui.interceptPanelComponents.trendInterceptBtn,'value');
    noTrendIntercept = get(gui.interceptPanelComponents.noTrendInterceptBtn,'value');
    intercept        = get(gui.interceptPanelComponents.interceptBtn,'value');
    quadtrend        = get(gui.interceptPanelComponents.quadTrendBtn,'value');
    
    if noTrendIntercept == 1 
        model = 'nc';
    elseif trendIntercept
        model = 'ct';
    elseif intercept
        model = 'c';
    elseif quadtrend
        model = 'ctt';
    else % shouldn't be the case
        model = 'nc';
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
        nb_errorWindow('The selected startDate is after the selected endDate')
        return
    end

    % Get test specific options
    %--------------------------------------------------------------
    if strcmpi(test,'adf')

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

        if lagSelect ~= 1 % user sets lag length 
            
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
        
    else
        
        autSelectBtn2 = gui.bandwidthComponents.autSelectBtn; 
        value         = get(autSelectBtn2,'value');
        if value
            
            % The user have choosen automatically band width 
            % selection
            methodSelectBox = gui.bandwidthComponents.methodSelectBox;
            string          = get(methodSelectBox,'string');
            index           = get(methodSelectBox,'value');
            bandWidthCrit   = string{index};
            bandWidth       = 3;
            
            switch lower(bandWidthCrit)
            
                case 'newey-west bandwidth',
                    bandWidthCrit = 'nw';
                case 'andrews bandwidth'
                    bandWidthCrit = 'a';
            end
            
        else
            
            % The user have select a band width manually
            bandwSelectBox  = gui.bandwidthComponents.bandwidthSelectBox;
            bandWidth       = get(bandwSelectBox,'string');
            bandWidth       = round(str2double(bandWidth));
            bandWidthCrit   = '';
            
            if isnan(bandWidth)
                nb_errorWindow('The bandwidth selection is not a number.')
                return
            elseif bandWidth < 0
                nb_errorWindow('The bandwidth selection is not a number greater than 0.')
                return
            end
            
        end
        
        % Kernel selected
        kernelBox = gui.bandwidthComponents.kernelBox;
        string    = get(kernelBox,'string');
        index     = get(kernelBox,'value');
        kernel    = string{index};
        
        switch lower(kernel)
            
            case 'bartlett kernel',
                kernel = 'bartlett';
            case 'parzen kernel'
                kernel = 'parzen';
            case 'quadratic spectral kernel'
                kernel = 'quadratic';
        end
        
    end

    % Check for nan values
    %----------------------
    nanValues = isnan(dataT.data);
    if  any(nanValues(:)) 
        nb_errorWindow('Cannot do cointegration test on unbalanced datasets (has nan values)');
        return
    end
    
    % Do the test
    %--------------------------------------------------------------
    switch test

        case 'adf'

            try
            
                temp = nb_cointTest(dataT,'eg',...
                    'test',             test,...
                    'nLags',            nLags,...
                    'dependent',        dependent,...
                    'maxLags',          maxLags,...
                    'lagLengthCrit',    lagLengthCrit,...
                    'model',            model,...
                    'transformation',   transformation);
                
            catch Err
                
                nb_errorWindow('Cointegration test failed. MATLAB error: ', Err);
                return
                
            end
                
%         case 'pp'
% 
%             try
%             
%                 temp = nb_cointTest(gui.data,type,...
%                     'bandWidth',                bandWidth,...
%                     'bandWidthCrit',            bandWidthCrit,...
%                     'freqZeroSpectrumEstimator',kernel,...
%                     'model',                    model,...
%                     'transformation',           transformation);
%             
%             catch Err
%                 
%                 nb_errorWindow('Cointegration test failed. MATLAB error: ', Err);
%                 return
%                 
%             end

        otherwise
            nb_errorWindow('This test type is not yet avalible');
            return
    end

    % Create new window with results
    %--------------------------------------------------------------
    results           = print(temp);
    name              = [gui.parent.guiName ': Cointegration Test, ' testType];
    nb_printResults(results, name);

end


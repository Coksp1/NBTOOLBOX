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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get test type
    %--------------------------------------------------------------
    index = get(gui.testTypeBox,'value');
    string = get(gui.testTypeBox,'string');
    testType = string{index};

    switch testType 
        case 'Augmented Dickey-Fuller'

            type = 'adf';

        case 'Phillips-Perron'

            type = 'pp';

        case 'Kwiatkowski-Phillips-Schmidt-Shin'

            type = 'kpss';
            nb_errorWindow('Kwiatkowski-Phillips-Schmidt-Shin test for unit root is not yet supported.')
            return

    end

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

    if noTrendIntercept == 1 
        model = 'ar';
    else
        if trendIntercept
            model = 'ts';
        else
            model = 'ard'; 
        end
    end

    % Get test specific options
    %--------------------------------------------------------------
    if strcmpi(type,'adf')

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
            maxLags = maxLagSelect;
            
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
    
    % Get selected window
    %--------------------
    string = get(gui.windowComponents.startDate,'string');
    valueS = get(gui.windowComponents.startDate,'value');
    startD = string{valueS};
    
    string = get(gui.windowComponents.endDate,'string');
    valueE = get(gui.windowComponents.endDate,'value');
    endD   = string{valueE};
    
    if length(string) - valueE + 1 <= valueS
        nb_errorWindow('The selected start date is after or equal to the selected end date.')
        return
    end
       
    string   = get(gui.windowComponents.variable,'string');
    value    = get(gui.windowComponents.variable,'value');
    variable = string(value);
    if strcmpi(variable{1},'all')
        variable = {};
    end
    
    dataT = window(gui.data,startD,endD,variable);

    % Check for nans
    tested = dataT.data;
    if any(isnan(tested(:)))
        nb_errorWindow('The selected window result in a unbalanced sample')
        return
    end
    
    % Check the sample length
    dof = 11;
    if strcmpi(type,'adf')
        
        if maxLags > dataT.numberOfObservations-dof
            nb_errorWindow(['The max lag length selected is to large to be tested. Max is ' int2str(dataT.numberOfObservations-dof)])
            return
        end
        
    elseif strcmpi(type,'pp')
        
        if ~isempty(bandWidthCrit)
            
            if dataT.numberOfObservations < 9 + dof
                nb_errorWindow(['The input data must have at least ' int2str(9 + dof) ' periods.'])
                return
            end
            
        else
            if dataT.numberOfObservations < bandWidth + dof
                nb_errorWindow(['The input data must have at least ' int2str(bandWidth + dof) ' periods.'])
                return
            end 
        end
        
    end
    
    % Do the test
    %--------------------------------------------------------------
    switch type

        case 'adf'

            try
            
                temp = nb_unitRootTest(dataT,type,...
                    'nLags',            nLags,...
                    'maxLags',          maxLags,...
                    'lagLengthCrit',    lagLengthCrit,...
                    'model',            model,...
                    'transformation',   transformation);
                
            catch Err
                
                nb_errorWindow('Unit root test failed. MATLAB error: ', Err);
                return
                
            end
                
        case 'pp'

            try
            
                temp = nb_unitRootTest(dataT,type,...
                    'bandWidth',                bandWidth,...
                    'bandWidthCrit',            bandWidthCrit,...
                    'freqZeroSpectrumEstimator',kernel,...
                    'model',                    model,...
                    'transformation',           transformation);
            
            catch Err
                
                nb_errorWindow('Unit root test failed. MATLAB error: ', Err);
                return
                
            end

        otherwise
            nb_errorWindow('This test type is not yet avalible');
            return
    end

    % Create new window with results
    %--------------------------------------------------------------
    results           = print(temp);
    name              = [gui.parent.guiName ': Unit Root Test, ' testType];
    nb_printResults(results, name);

end


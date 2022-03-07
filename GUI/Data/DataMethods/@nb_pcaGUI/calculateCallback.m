function calculateCallback(gui,~,~)
% Syntax:
%
% calculateCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the selected variables
    selected  = get(gui.components.selectionPanel.assignPanel.children(2),'string');
    nSelected = length(selected);
    
    % Get the selected options
    test = get(gui.components.manualButton,'value');
    if ~test
        nFactors   = [];
        maxFactors = get(gui.components.maxFactors,'string');
        maxFactors = round(str2double(maxFactors));
        if isnan(maxFactors)
            nb_errorWindow('The max number of factors must be a number')
            return
        end
        if maxFactors < 1
            nb_errorWindow('The max number of factors must be a number greater than 0')
            return
        end
        if maxFactors > nSelected
            nb_errorWindow('The max number of factors can not be greater than the number of selected variables')
            return
        end
        criteria = get(gui.components.criteria,'value');
        
    else
        maxFactors = [];
        criteria   = 7;
        nFactors   = get(gui.components.nFactors,'string');
        nFactors   = round(str2double(nFactors));
        if isnan(nFactors)
            nb_errorWindow('The number of factors must be a number')
            return
        end
        if nFactors < 1
            nb_errorWindow('The number of factors must be a number greater than 0')
            return
        end
        if nFactors > nSelected
            nb_errorWindow('The number of factors can not be greater than the number of selected variables')
            return
        end
        
    end
    
    string = get(gui.components.transformation,'string');
    value  = get(gui.components.transformation,'value');
    trans  = string{value};
    
    string = get(gui.components.output,'string');
    value  = get(gui.components.output,'value');
    output = string{value};
    
    switch lower(output)
        
        case 'factors'
            output = 'F';
        case 'coefficients'
            output = 'LAMBDA';
        case 'explained'
            output = 'expl';
    end
    
    string = get(gui.components.startDate,'string');
    valueS = get(gui.components.startDate,'value');
    startD = string{valueS};
    
    string = get(gui.components.endDate,'string');
    valueE = get(gui.components.endDate,'value');
    endD   = string{valueE};
    
    if valueE - valueS < 9
        nb_errorWindow('The selected sample must have at least 10 periods')
        return
    end
    
    % Shorten the sample
    dataT = window(gui.data,startD,endD,selected);
    
    % Check for missing observations
    if any(~isfinite(dataT.data(:)))
        nb_errorWindow(['Selected sample cannot contain missing observations or inf; ' ...
            char(10) getRealStartDate(dataT,'default','all') '-' getRealEndDate(dataT,'default','all')]);
        return
    end
    
    % Do the calculations
    try
        out = pca(dataT,nFactors,'svd','output',output,'rMax',maxFactors,...
                'crit',criteria,'trans',trans);
    catch Err
        nb_errorWindow('Cannot calculate PCA.',Err)
    end
        
    % Display results in own spreadsheet
    nb_spreadsheetAdvGUI(gui.parent,out);
    
end

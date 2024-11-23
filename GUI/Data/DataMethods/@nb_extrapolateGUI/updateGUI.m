function updateGUI(gui)
% Syntax:
%
% updateGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    components = gui.components;
    
    set(components.variables, 'String', gui.data.variables);
    set(components.method, ...
        'String', {'Last observation', 'Copula', 'AR'}, ...
        'UserData', {'end', 'copula', 'ar'});
    
    % Date/periods
    set(components.toDateString, 'String', nb_conditional(...
        nb_getUIControlValue(components.periodCheckBox), ...
        'Periods:', ...
        'To date:'));
    
    % Show/hide method specific options
    methodOptions = components.methodOptions;
    structfun(@(crawler) set(crawler, 'Visible', 'off'), methodOptions);
    
    selectedMethod = nb_getUIControlValue(components.method);
    switch lower(selectedMethod)
        case 'copula'
            optionNames = {...
                'alphaLabel', 'alpha', ...
                'checkLabel', 'check', ...
                'nLagsLabel', 'nLags', ...
                'drawsLabel', 'draws'};
        case 'ar'
            optionNames = {...
                'constantLabel', 'constant'};
        otherwise
            optionNames = {};
    end
    
    visibleMethodOptions = nb_keepFields(methodOptions, optionNames);      
    structfun(@(crawler) set(crawler, 'Visible', 'on'), visibleMethodOptions);
    
    % Enable/disable controls
    set(methodOptions.alpha, 'Enable', nb_conditional(...
        nb_getUIControlValue(methodOptions.check), 'on', 'off'));
end

function extrapolateCallback(gui, varargin)
% Syntax:
%
% extrapolateCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    components = gui.components;
    variables  = nb_getUIControlValue(components.variables);
    if get(components.periodCheckBox,'value')
        toDate = nb_getUIControlValue(components.toDate,'numeric');
    else
        toDate = nb_getUIControlValue(components.toDate);
    end
    
    methodOptions           = components.methodOptions;
    optionalInputs.method   = nb_getUIControlValue(components.method, 'UserData');
    optionalInputs.alpha    = nb_getUIControlValue(methodOptions.alpha, 'numeric');
    optionalInputs.check    = nb_getUIControlValue(methodOptions.check, 'logical');
    optionalInputs.nLags    = nb_getUIControlValue(methodOptions.nLags, 'numeric');
    optionalInputs.draws    = nb_getUIControlValue(methodOptions.draws, 'numeric');
    optionalInputs.constant = nb_getUIControlValue(methodOptions.constant, 'logical');

    try
        gui.data = extrapolate(gui.data, variables, toDate, optionalInputs);
    catch Err
        nb_errorWindow('An error occured during extrapolation.', Err);
        return
    end
    
    close(gui.figureHandle);
    notify(gui, 'methodFinished');
end

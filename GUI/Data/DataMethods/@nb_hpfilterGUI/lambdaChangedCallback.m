function lambdaChangedCallback(gui,hObject,~)
% Syntax:
%
% lambdaChangedCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    string = get(hObject,'string');
    num    = round(str2double(string));
    if isnan(num)
        nb_errorWindow('The lambda option must be a number greater the 0.')
        return
    elseif num <= 0
        nb_errorWindow('The lambda option must be a number greater the 0.')
        return
    end
    
    % Update the postfixes if they have not been edited
    gapPostfix   = get(gui.edit2,'string');
    trendPostfix = get(gui.edit3,'string');

    if strcmpi(gapPostfix,['_hpgap' gui.oldLambda])
        set(gui.edit2,'string',['_hpgap' string]);
    end
    if strcmpi(trendPostfix,['_hptrend' gui.oldLambda])
        set(gui.edit3,'string',['_hptrend' string]);
    end
    
    % Update properties
    gui.oldLambda = string;
    
end

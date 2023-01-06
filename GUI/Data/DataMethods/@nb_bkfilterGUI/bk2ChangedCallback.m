function bk2ChangedCallback(gui,hObject,~)
% Syntax:
%
% bk2ChangedCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    string = get(hObject,'string');
    num    = round(str2double(string));
    if isnan(num)
        nb_errorWindow('The upper bound of the band pass filter must be a number greater the 0.')
        return
    elseif num <= 0
        nb_errorWindow('The upper bound of the band pass filter must be a number greater the 0.')
        return
    end
    
    % Update the postfixes if they have not been edited
    gapPostfix   = get(gui.edit2,'string');
    trendPostfix = get(gui.edit3,'string');

    if strcmpi(gapPostfix,['_bkgap_' gui.oldBK1 '_' gui.oldBK2])
        set(gui.edit2,'string',['_bkgap_' gui.oldBK1 '_' string]);
    end
    if strcmpi(trendPostfix,['_bktrend_' gui.oldBK1 '_' gui.oldBK2])
        set(gui.edit3,'string',['_bktrend_' gui.oldBK1 '_' string]);
    end
    
    % Update properties
    gui.oldBK2 = string;
    
end

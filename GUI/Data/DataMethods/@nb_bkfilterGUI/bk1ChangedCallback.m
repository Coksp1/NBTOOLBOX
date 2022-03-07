function bk1ChangedCallback(gui,hObject,~)
% Syntax:
%
% bk1ChangedCallback(gui,hObject,event)
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
        nb_errorWindow('The lower bound of the band pass filter must be a number greater the 0.')
        return
    elseif num <= 0
        nb_errorWindow('The lower bound of the band pass filter must be a number greater the 0.')
        return
    end
    
    % Update the postfixes if they have not been edited
    gapPostfix   = get(gui.edit2,'string');
    trendPostfix = get(gui.edit3,'string');

    if strcmpi(gapPostfix,['_bkgap' gui.oldBK1 '_' gui.oldBK2])
        set(gui.edit2,'string',['_bkgap' string '_' gui.oldBK2]);
    end
    if strcmpi(trendPostfix,['_bktrend' gui.oldBK1 '_' gui.oldBK2])
        set(gui.edit3,'string',['_bktrend' string '_' gui.oldBK2]);
    end
    
    % Update properties
    gui.oldBK1 = string;
    
end

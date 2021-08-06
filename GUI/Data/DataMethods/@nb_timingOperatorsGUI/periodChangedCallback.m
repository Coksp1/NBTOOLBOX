function periodChangedCallback(gui,hObject,~)
% Syntax:
%
% periodChangedCallback(gui,hObject,event)
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
        nb_errorWindow(['The number of periods must be given as a number. Not ''' num '''.'])
        return
    end
    
    % Update the postfix if it has not been edited
    postfix = get(gui.edit2,'string');
    if strcmpi(postfix,['_' gui.type gui.oldPeriod])
        set(gui.edit2,'string',['_' gui.type string]);
    end
    
    % Update property
    gui.oldPeriod = string;
    
end

function bigLetterCallback(gui,hObject,~) 
% Syntax:
%
% bigLetterCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    string = get(hObject,'checked');
    if strcmpi(string,'on')
        set(hObject,'checked','off');
        gui.package.bigLetter = false;
    else
        set(hObject,'checked','on');
        gui.package.bigLetter = true;
    end

    gui.changed = 1;
    
end

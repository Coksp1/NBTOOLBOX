function bigLetterCallback(gui,hObject,~) 
% Syntax:
%
% bigLetterCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

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

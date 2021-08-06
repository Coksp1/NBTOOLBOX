function setExcelStyle(gui,hObject,~) 
% Syntax:
%
% setExcelStyle(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    string = get(hObject,'checked');
    if strcmpi(string,'on')
        set(hObject,'checked','off');
        gui.package.excelStyle = 'FSR';
    else
        set(hObject,'checked','on');
        gui.package.excelStyle = 'MPR';
    end

    gui.changed = 1;
    
end

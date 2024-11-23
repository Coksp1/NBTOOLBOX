function setZeroLowerBound(gui,hObject,~) 
% Syntax:
%
% setZeroLowerBound(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    string = get(hObject,'checked');
    if strcmpi(string,'on')
        set(hObject,'checked','off');
        gui.package.zeroLowerBound = 0;
    else
        set(hObject,'checked','on');
        gui.package.zeroLowerBound = 1;
    end

    gui.changed = 1;
    
end

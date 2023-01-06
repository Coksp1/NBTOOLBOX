function helpCallback(gui,~,~)
% Syntax:
%
% helpCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    label = get(gui.help,'label');
    
    if strcmpi(label, 'help')
        set(gui.panel1, 'visible', 'off');
        set(gui.panel2,'visible','on');
        set(gui.help,'label','Create variable');
        
    else
        set(gui.panel1, 'visible', 'on');
        set(gui.panel2,'visible','off');
        set(gui.help,'label','Help');
    end 
          
end

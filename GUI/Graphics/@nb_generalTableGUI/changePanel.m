function changePanel(gui,~,event)
% Syntax:
%
% changePanel(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback when changing the panel
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    old  = event.OldValue;
    type = get(old,'string');
    switch lower(type(1,:))
        case 'table'
            set(gui.panelHandle1,'visible','off');
        case 'text'
            set(gui.panelHandle2,'visible','off');
        case 'look up'
            set(gui.panelHandle3,'visible','off');
        case 'observations'
            set(gui.panelHandle4,'visible','off'); 
        case 'template'
            set(gui.panelHandle5,'visible','off'); 
    end

    new  = event.NewValue;
    type = get(new,'string');
    switch lower(type(1,:))
        case 'table'
            set(gui.panelHandle1,'visible','on');
        case 'text'
            set(gui.panelHandle2,'visible','on');
        case 'look up'
            set(gui.panelHandle3,'visible','on');
        case 'observations'
            set(gui.panelHandle4,'visible','on');    
        case 'template'
            set(gui.panelHandle5,'visible','on');     
    end

    
end

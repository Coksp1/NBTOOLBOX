function popupCallback(gui,~,~)
% Syntax:
%
% popupCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Function called when the popupmenu is changed. Switches 
% between the identifier box and the variable select box.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get value of renamepopup
    list     = get(gui.renamepopup,'string');
    index    = get(gui.renamepopup,'value');
    selected = list{index};
    
    % Make the switch   
    switch selected 
        case ['Single ' gui.type]
            set(gui.idText,'visible','off');
            set(gui.idBox,'visible','off');
            set(gui.popupmenu,'visible','on');
            set(gui.selectText,'visible','on');
            
        case ['All ' gui.type 's' ]
            set(gui.idText,'visible','on');
            set(gui.idBox,'visible','on');
            set(gui.popupmenu,'visible','off');
            set(gui.selectText,'visible','off')
            
            
    end
end


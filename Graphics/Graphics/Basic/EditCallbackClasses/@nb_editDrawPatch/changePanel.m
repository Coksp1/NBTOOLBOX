function changePanel(gui,hObject,event)
% Callback when changing the panel

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    old  = event.OldValue;
    type = get(old,'string');
    
    switch lower(type)
        case 'look'
            set(gui.panelHandle1,'visible','off');    
        case 'general'
            set(gui.panelHandle2,'visible','off');
        
    end

    new  = event.NewValue;
    type = get(new,'string');
    
    switch lower(type)
        case 'look'
            set(gui.panelHandle1,'visible','on');   
        case 'general'
            set(gui.panelHandle2,'visible','on');
    end
    
end

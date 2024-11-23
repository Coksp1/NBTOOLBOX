function changePanel(gui,hObject,event)
% Callback when changing the panel

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    old  = event.OldValue;
    type = get(old,'string');
    
    switch lower(type)
        case 'text'
            set(gui.panelHandle1,'visible','off');    
        case 'general'
            set(gui.panelHandle3,'visible','off');
        
    end

    new  = event.NewValue;
    type = get(new,'string');
    
    switch lower(type)
        case 'text'
            set(gui.panelHandle1,'visible','on');   
        case 'general'
            set(gui.panelHandle3,'visible','on');
    end
    
end

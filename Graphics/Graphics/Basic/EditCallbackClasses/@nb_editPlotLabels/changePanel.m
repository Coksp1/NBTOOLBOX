function changePanel(gui,~,event)
% Callback when changing the panel

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    old  = event.OldValue;
    type = get(old,'string');
    switch lower(type)
        case 'text'
            set(gui.panelHandle1,'visible','off');
        case 'text box'
            set(gui.panelHandle2,'visible','off');
        case 'location'
            set(gui.panelHandle3,'visible','off');
        case 'general'
            set(gui.panelHandle4,'visible','off');
        
    end

    new  = event.NewValue;
    type = get(new,'string');
    switch lower(type)
        case 'text'
            set(gui.panelHandle1,'visible','on'); 
        case 'text box'
            set(gui.panelHandle2,'visible','on');
        case 'location'
            set(gui.panelHandle3,'visible','on');    
        case 'general'
            set(gui.panelHandle4,'visible','on');
    end
    
end

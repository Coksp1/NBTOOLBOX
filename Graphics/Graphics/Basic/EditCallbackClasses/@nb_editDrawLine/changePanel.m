function changePanel(gui,~,event)
% Callback when changing the panel

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    old  = event.OldValue;
    type = get(old,'string');
    
    switch lower(type)
        case 'location'
            set(gui.panelHandle1,'visible','off');
        case 'line'
            set(gui.panelHandle2,'visible','off');
        case 'general'
            set(gui.panelHandle3,'visible','off');
    end

    new  = event.NewValue;
    type = get(new,'string');
    
    switch lower(type)
        case 'location'
            set(gui.panelHandle1,'visible','on');
        case 'line'
            set(gui.panelHandle2,'visible','on');
        case 'general'
            set(gui.panelHandle3,'visible','on');
    end
    
end

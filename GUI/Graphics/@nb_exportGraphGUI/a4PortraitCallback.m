function a4PortraitCallback(gui,hObject,~)
% Syntax:
%
% a4PortraitCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~get(hObject,'value')
        set(gui.rb1,'enable','on');
        set(gui.rb2,'enable','on');
        set(gui.rb3,'enable','on');
    else
        set(gui.rb1,'enable','off');
        set(gui.rb2,'enable','off');
        set(gui.rb3,'enable','off');
    end

end

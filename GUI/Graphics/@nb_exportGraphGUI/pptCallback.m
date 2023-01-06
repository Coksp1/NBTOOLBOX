function pptCallback(gui,hObject,~)
% Syntax:
%
% pptCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~get(hObject,'value')
        set(gui.rb2,'enable','on');
        set(gui.rb3,'enable','on');
        set(gui.cropBoxes,'enable','off');
    else
        set(gui.rb2,'enable','off');
        set(gui.rb3,'enable','off');
        set(gui.cropBoxes,'enable','on')
    end

end

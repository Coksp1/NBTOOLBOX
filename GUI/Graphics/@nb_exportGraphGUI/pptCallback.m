function pptCallback(gui,hObject,~)
% Syntax:
%
% pptCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

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

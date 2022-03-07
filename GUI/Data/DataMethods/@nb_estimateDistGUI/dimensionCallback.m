function dimensionCallback(gui,~,~)
% Syntax:
%
% dimensionCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if get(gui.pop3,'value') == 2
        enable = 'off';
    else
        enable = 'on';
    end
    set(gui.list1,'enable',enable);
    set(gui.rball,'enable',enable);

end

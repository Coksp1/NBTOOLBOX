function changeFanMethod(gui,~,~)
% Syntax:
%
% changeFanMethod(gui,handle,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    method = nb_getUIControlValue(gui.handle5);
    switch lower(method)
        case {'percentiles','shaded'}
            enable   = 'on';
            visible1 = 'on';
            visible2 = 'off';
        case 'graded'
            enable   = 'off';
            visible1 = 'off';
            visible2 = 'on';
    end
    
    set(gui.table,'enable',enable);
    set(gui.handle3,'visible',visible1);
    set(gui.handle4,'visible',visible1);
    set(gui.handle8,'visible',visible1);
    set(gui.handle9,'visible',visible1);
    set(gui.handle6,'visible',visible2);
    set(gui.handle7,'visible',visible2);
    set(gui.handle10,'visible',visible2);
    set(gui.handle11,'visible',visible2);
    
end

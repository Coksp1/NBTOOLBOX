function fillPanelGUI(gui)
% Syntax:
%
% fillPanelGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    f = gui.figureHandle;
    
    info = gui.sources.(gui.name).(gui.currSource);
    
    % Common for all source types
    set(gui.editBox1, 'string',info.source);
    
    % Clear all other inputs and enable
    set(gui.editBox2,'string','','enable','on');
    set(gui.editBox3,'string','','enable','on');
    set(gui.editBox4,'string','','enable','on');
    set(gui.editBox5,'string','','enable','on');
    set(gui.editBox6,'string','','enable','on');
    
    if strcmpi(info.sourceType,'db')
        fillDBGUI(gui)
    elseif strcmpi(info.sourceType,'xls')
        fillXLSGUI(gui)
    elseif contains(info.sourceType,'private')
        fillPrivateGUI(gui)
    else
        fillNoSourceGUI(gui)
    end
    
    % Display window
    set(f,'visible','on')
    
end









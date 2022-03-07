function fillDBGUI(gui)
% Syntax:
%
% fillDBGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    info = gui.sources.(gui.name).(gui.currSource);
   
    set(gui.editBox2,'string',info.variables);
    set(gui.editBox3,'string',info.startDate);
    set(gui.editBox4,'string',info.endDate);
    set(gui.editBox5,'string',info.vintage);
    set(gui.editBox6,'enable','off'); 
    
end

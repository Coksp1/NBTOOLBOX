function fillXLSGUI(gui)
% Syntax:
%
% fillXLSGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    info = gui.sources.(gui.name).(gui.currSource);
   
    set(gui.editBox2,'string',info.variables);
    set(gui.editBox3,'string',info.startDate);
    set(gui.editBox4,'string',info.endDate);
    set(gui.editBox5,'enable','off');
    set(gui.editBox6,'string',info.sheet); 
         
end

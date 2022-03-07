function fillPrivateGUI(gui)
% Syntax:
%
% fillPrivateGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    info = gui.sources.(gui.name).(gui.currSource);
   
    set(gui.editBox2,'string',info.variables);
    set(gui.editBox3,'enable','off');
    set(gui.editBox4,'enable','off');
    set(gui.editBox5,'enable','off');
    set(gui.editBox6,'enable','off'); 
        
end

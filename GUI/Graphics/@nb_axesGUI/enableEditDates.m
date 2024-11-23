function enableEditDates(gui,hObject,~,type)
% Syntax:
%
% enableEditDates(gui,hObject,event,type)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotter = gui.plotter;

    if strcmp(get(get(hObject,'selectedObject'),'tag'),'auto')
        
        if strcmpi(type,'startGraph')
            
            plotter.setSpecial('manuallySetStartGraph',0);
            set(gui.editBox1,'enable','off');
            
        else % endGraph
            
            plotter.setSpecial('manuallySetEndGraph',0);
            set(gui.editBox2,'enable','off');
            
        end
        
        % Udate the graph
        notify(gui,'changedGraph');
        
    else
        
        if strcmpi(type,'startGraph')
            set(gui.editBox1,'enable','on','string',toString(plotter.startGraph));
        else
            set(gui.editBox2,'enable','on','string',toString(plotter.endGraph));
        end
        
    end

end

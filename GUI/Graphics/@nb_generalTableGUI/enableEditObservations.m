function enableEditObservations(gui,hObject,~,type)
% Syntax:
%
% enableEditObservations(gui,hObject,event,type)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotter = gui.plotter;

    if strcmp(get(get(hObject,'selectedObject'),'tag'),'auto')
        
        if strcmpi(type,'startTable')
            
            plotter.setSpecial('manuallySetStartTable',0);
            set(gui.editBox1,'enable','off');
            
        else % endGraph
            
            plotter.setSpecial('manuallySetEndTable',0);
            set(gui.editBox2,'enable','off');
            
        end
        
        % Udate the graph
        notify(gui,'changedGraph');
        
    else
        
        if strcmpi(type,'startTable')
            set(gui.editBox1,'enable','on','string',toString(plotter.startTable));
        else
            set(gui.editBox2,'enable','on','string',toString(plotter.endTable));
        end
        
    end

end

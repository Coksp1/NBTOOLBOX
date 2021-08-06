function enableEditXLim(gui,hObject,~,type)
% Syntax:
%
% enableEditXLim(gui,hObject,event,type)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotter = gui.plotter;

    if strcmp(get(get(hObject,'selectedObject'),'tag'),'auto')
        
        if strcmpi(type,'lower')
            plotter.xLim(1) = nan;
            set(gui.editBox1,'enable','off','string','');
        else
            plotter.xLim(2) = nan;
            set(gui.editBox2,'enable','off','string','');
        end
        
        % Udate the graph
        notify(gui,'changedGraph');
        
    else
        
        if isempty(plotter.xLim)
            plotter.xLim = nan(1,2);
        end
        
        if strcmpi(type,'lower')
            set(gui.editBox1,'enable','on');
        else
            set(gui.editBox2,'enable','on');
        end
        
    end

end

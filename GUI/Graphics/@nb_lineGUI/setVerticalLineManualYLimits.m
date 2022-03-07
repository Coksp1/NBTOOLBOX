function setVerticalLineManualYLimits(gui,hObject,~)
% Syntax:
%
% setVerticalLineManualYLimits(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get state
    value = get(hObject,'value');

    % Get selected line object
    index = get(gui.popupmenu1,'value');
    
    plotterT = gui.plotter;
    
    if value
    
        % Assign graph object
        ax      = get(plotterT,'axesHandle');
        plotterT.verticalLineLimit{index} = ax.yLim; 

        % Update panel
        set(gui.editbox4,'string',num2str(ax.yLim(1)),'enable','on');
        set(gui.editbox5,'string',num2str(ax.yLim(2)),'enable','on');
        
    else
        
        % Assign graph object
        plotterT.verticalLineLimit{index} = {}; 

        % Update panel
        set(gui.editbox4,'string','','enable','off');
        set(gui.editbox5,'string','','enable','off');
        
    end
    
    % Notify listeners
    notify(gui,'changedGraph');

end

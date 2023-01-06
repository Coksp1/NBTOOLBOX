function enableEditYLim(gui,hObject,~,type,side)
% Syntax:
%
% enableEditYLim(gui,hObject,event,type,side)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    plotter = gui.plotter;
    
    if strcmpi(side,'left')
        yLim  = plotter.yLim;
        eBoxL = gui.editBox3;
        eBoxU = gui.editBox4;
    else
        yLim = plotter.yLimRight;
        eBoxL = gui.editBox5;
        eBoxU = gui.editBox6;
    end

    if strcmp(get(get(hObject,'selectedObject'),'tag'),'auto')
        
        if strcmpi(type,'lower')
            yLim(1) = nan;
            set(eBoxL,'enable','off','string','');
        else
            yLim(2) = nan;
            set(eBoxU,'enable','off','string','');
        end
        
        if strcmpi(side,'left')
            plotter.yLim = yLim;
        else
            plotter.yLimRight = yLim;
        end
        
        % Udate the graph
        notify(gui,'changedGraph');
        
    else
        
        if isempty(yLim)
            yLim = nan(1,2);
        end
        
        if strcmpi(side,'left')
            plotter.yLim = yLim;
        else
            plotter.yLimRight = yLim;
        end
        
        if strcmpi(type,'lower')
            set(eBoxL,'enable','on');
        else
            set(eBoxU,'enable','on');
        end
        
    end

end

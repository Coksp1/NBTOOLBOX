function setYLim(gui,hObject,~,type,side)
% Syntax:
%
% setYLim(gui,hObject,event,side)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotter = gui.plotter;

    % Get the value selected
    strs = get(hObject,'string');
    if isempty(strs)
        sp = nan;
    else
        sp = str2double(strs);
        if isnan(sp)
            nb_errorWindow(['The ' side ' Y-Limit (' type ') must be a number.'])
            return
        end
    end

    % Set the plotter object
    if strcmpi(side,'left')
        yLim = plotter.yLim;
    else
        yLim = plotter.yLimRight;
    end
    
    if strcmpi(type,'lower')
        
        if ~isnan(yLim(2))
            
            if sp > yLim(2)
                nb_errorWindow(['The lower ' side ' Y-Limit cannot be greater then the upper ' side ' Y-Limit.'])
                return
            end
            
        end
        
        if strcmpi(side,'left')
            plotter.yLim(1) = sp;
        else
            plotter.yLimRight(1) = sp;
        end
        
    else
        
        if ~isnan(yLim(1))
            
            if sp < yLim(1)
                nb_errorWindow(['The upper ' side ' Y-Limit cannot be less then the lower ' side ' Y-Limit.'])
                return
            end
            
        end
        if strcmpi(side,'left')
            plotter.yLim(2) = sp;
        else
            plotter.yLimRight(2) = sp;
        end
        
    end

    % Udate the graph
    notify(gui,'changedGraph');

end

function setXLim(gui,hObject,~,type)
% Syntax:
%
% setXLim(gui,hObject,event,type)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotter = gui.plotter;

    % Get the value selected
    strs = get(hObject,'string');
    if isempty(strs)
        sp = nan;
    else
        sp = str2double(strs);
        if isnan(sp)
            nb_errorWindow(['The X-Limit (' type ') must be a number.'])
            return
        end
    end

    % Set the plotter object
    if strcmpi(type,'lower')
        
        if ~isnan(plotter.xLim(2))
            
            if sp > plotter.xLim(2)
                nb_errorWindow('The lower X-Limit cannot be greater then the upper X-Limit.')
                return
            end
            
        end
        plotter.xLim(1) = sp;
        
    else
        
        if ~isnan(plotter.xLim(1))
            
            if sp < plotter.xLim(1)
                nb_errorWindow('The upper X-Limit cannot be less then the lower X-Limit.')
                return
            end
            
        end
        plotter.xLim(2) = sp;
        
    end

    % Udate the graph
    notify(gui,'changedGraph');

end

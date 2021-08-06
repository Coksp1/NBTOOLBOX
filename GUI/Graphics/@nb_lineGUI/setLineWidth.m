function setLineWidth(gui,hObject,~)
% Syntax:
%
% setLineWidth(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;

    % Get selected color
    string    = get(hObject,'string');
    lineWidth = str2double(string);
    
    if isnan(lineWidth)
        nb_errorWindow('The line width must be set to a number.')
        return
    elseif lineWidth <= 0
        nb_errorWindow(['The line width must be set to a number greater then 0. Is ' string '.'])
        return
    end
    
    if strcmpi(gui.type,'horizontal')
        plotterT.horizontalLineWidth = lineWidth;
    elseif strcmpi(gui.type,'vertical')
        plotterT.verticalLineWidth = lineWidth;  
    else
        % Update here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    end

    % Notify listeners
    notify(gui,'changedGraph');

end

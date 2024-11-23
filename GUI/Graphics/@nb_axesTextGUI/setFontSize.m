function setFontSize(gui,hObject,~)
% Syntax:
%
% setFontSize(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get value selected
    string = get(hObject,'string');
    value  = str2double(string);
    
    switch lower(gui.type)
        case 'title'
            text = 'title';
        case 'xlabel'
            text = 'x-axis label';
        otherwise
            text = 'y-axis label';
    end
    
    if isnan(value)
        nb_errorWindow(['The font size of the ' text ' must be a number between 0 and 1.'])
        return
    elseif value < 0 || value > 1
        nb_errorWindow(['The font size of the ' text ' must be a number between 0 and 1.'])
        return
    end
    
    % Assign graph object
    plotterT = gui.plotter;
    switch lower(gui.type)
        case 'title'
            plotterT.titleFontSize = value;
        case 'xlabel'
            plotterT.xLabelFontSize = value;
        case 'ylabel'
            plotterT.yLabelFontSize = value;
        otherwise
            plotterT.yLabelFontSize = value;
    end
    
    % Notify listeners
    notify(gui,'changedGraph');

end

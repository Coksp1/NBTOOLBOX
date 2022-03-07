function setAxesFontSize(gui,hObject,~)
% Syntax:
%
% setAxesFontSize(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

%     if strcmpi(gui.plotter.graphStyle,'mpr_white')
%         nb_errorWindow('It is not allowed to set the axes font size property of an advanced graph.')
%         set(hObject,'string',num2str(gui.plotter.axesFontSize));
%         return
%     end
        
    % Get value selected
    string = get(hObject,'string');
    value  = str2double(string);
    
    if isnan(value)
        nb_errorWindow('The font size of the axes must be a number between 0 and 1.')
        return
    elseif value < 0 || value > 1
        nb_errorWindow('The font size of the axes must be a number between 0 and 1.')
        return
    end
    
    % Assign graph object
    gui.plotter.axesFontSize = value;
    
    % Udate the graph
    notify(gui,'changedGraph');
    
end

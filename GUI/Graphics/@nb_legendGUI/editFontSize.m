function editFontSize(gui,hObject,~)
% Set font size option of the legend callback

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

%     if strcmpi(gui.plotter.graphStyle,'mpr_white')
%         nb_errorWindow('It is not allowed to set the legend font size property of an advanced graph.')
%         set(hObject,'string',num2str(gui.plotter.legFontSize));
%         return
%     end

    % Get value selected
    string = get(hObject,'string');
    value  = str2double(string);
    
    if isnan(value)
        nb_errorWindow('The font size of the legend must be a number between 0 and 1.')
        return
    elseif value < 0 || value > 1
        nb_errorWindow('The font size of the legend must be a number between 0 and 1.')
        return
    end
    
    % Assign graph object
    gui.plotter.legFontSize = value;
    
    % Notify listeners
    notify(gui,'changedGraph');

end

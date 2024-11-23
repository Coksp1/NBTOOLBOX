function setColor(gui,hObject,~,type)
% Syntax:
%
% setColor(gui,hObject,event,type)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if strcmpi(get(hObject,'style'),'slider')
        value = get(hObject,'value');
    else
        string = get(hObject,'string');
        value  = str2double(string);
        if isnan(value) || value > 256 || value < 0
            nb_errorWindow('The RGB colors must be a number between 0 and 256.')
            return
        end
        value = value/256;
    end
    
    switch lower(type)
        case 'red'
            ind = 1;
            set(gui.slider1,'value',value);
            set(gui.editbox1,'string',num2str(value*256));
        case 'green'
            ind = 2;
            set(gui.slider2,'value',value);
            set(gui.editbox2,'string',num2str(value*256));
        case 'blue'
            ind = 3;
            set(gui.slider3,'value',value);
            set(gui.editbox3,'string',num2str(value*256));
    end
    
    % Assign changes
    color      = get(gui.patchHandle,'faceColor');
    color(ind) = value;
    set(gui.patchHandle,'faceColor',color);
    gui.color  = color;
    
end

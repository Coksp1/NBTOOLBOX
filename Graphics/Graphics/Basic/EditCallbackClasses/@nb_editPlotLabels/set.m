function set(gui,hObject,~,type)
% Callback function for setting properties of the text box

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    format = gui.format;

    switch lower(type)
        
        case 'backgroundcolor'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the nb_plotLabels object (and its children)
            if index == 1
                format.backgroundColor = 'none';
            else
                format.backgroundColor = endc(index - 1,:);
            end
            
        case 'color'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the nb_plotLabels object (and its children)
            format.color = endc(index,:);
            
        case 'decimals'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = str2double(string{index});
           
            % Update the nb_plotLabels object
            format.decimals = selected;
            
        case 'displayed'
            
            format.displayed = ~get(hObject,'value');
            
        case 'edgecolor'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the nb_plotLabels object (and its children)
            if index == 1
                format.edgeColor = 'none';
            else
                format.edgeColor = endc(index - 1,:);
            end
            
        case 'fontangle'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            format.fontAngle = selected;
            
        case 'fontsize'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected font size must be a number greater then 0.')
                return
            end
            
            % Update the nb_plotLabels object (and its children)
            format.fontSize = selected;
            
        case 'fontweight'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_plotLabels object (and its children)
            format.fontWeight = selected;
          
        case 'horizontalalignment'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            format.horizontalAlignment = selected;    
            
        case 'interpreter'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_plotLabels object (and its children)
            format.interpreter = selected;
            
        case 'language'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_plotLabels object (and its children)
            set(gui.parent,'language',selected);
            return
            
        case 'linestyle'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            format.lineStyle = selected;
            
        case 'linewidth'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected line width must be a number greater then 0.')
                return
            end
            
            % Update the nb_textBox object (and its children)
            format.lineWidth = selected;
            
        case 'location'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_plotLabels object
            format.location = selected;
            
        case 'margin'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected margin must be a number greater then 0.')
                return
            end
            
            % Update the nb_textBox object (and its children)
            format.margin = selected;
            
        case 'position'
            
            % Get the value selected
            string   = get(hObject,'string');
            if isempty(string)
                selected = [];
            else
                selected = str2double(string);
                if isnan(selected)
                    nb_errorWindow('The selected font size must be a number.');
                    return
                end
            end
            
            % Update the nb_plotLabels object (and its children)
            format.position = selected;    
            
        case 'rotation'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            if isnan(selected)
                nb_errorWindow('The selected font size must be a number.');
                return
            end
            
            % Update the nb_plotLabels object (and its children)
            format.rotation = selected;
            
        case 'string'
            
            % Get the value selected
            string   = get(hObject,'string');
            
            % Update the nb_plotLabels object (and its children)
            format.string = string;
            
        case 'space'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected)
                nb_errorWindow('The selected space must be a number.')
                return
            end
            
            % Update the nb_plotLabels object
            format.space = selected;
            
        case 'textformat'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_plotLabels object
            format.textFormat = selected;
            
        case 'valuetype'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_plotLabels object
            format.valueType = selected;
            
        case 'verticalalignment'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            format.verticalAlignment = selected; 
            
    end
    
    gui.format = format;
    setFormat(gui);
    notify(gui.parent,'annotationEdited')

end

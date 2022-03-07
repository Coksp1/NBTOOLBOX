function set(gui,hObject,~,type)
% Callback function for setting properties of the text box

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    colorBar = gui.parent;

    switch lower(type)
           
        case 'direction'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_colorbar object (and its children)
            set(colorBar,'direction',selected);
            
        case 'fontsize'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected font size must be a number greater then 0.')
                return
            end
            
            % Update the nb_textBox object (and its children)
            set(colorBar,'fontSize',selected);
            
        case 'fontweight'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_colorbar object (and its children)
            colorBar.set('fontWeight',selected);
            
        case 'interpreter'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            colorBar.set('interpreter',selected);
            
        case 'invert'
            
            % Get the value selected
            selected = get(hObject,'value');
            colorBar.set('invert',logical(selected));
            
        case 'space'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            if isnan(selected) 
                nb_errorWindow('The selected space must be a number.')
                return
            end
            
            % Update the nb_textBox object (and its children)
            colorBar.set('space',selected);
              
    end
    
    notify(colorBar,'annotationEdited')

end

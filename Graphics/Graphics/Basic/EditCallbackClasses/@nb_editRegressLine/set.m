function set(gui,hObject,~,type)
% Callback function for setting properties of the text box

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj = gui.parent;

    switch lower(type)
        
        case 'decimals'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the object
            obj.decimals = str2double(selected);
          
        case 'textbackgroundcolor'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the object
            if index == 1
                obj.textBackgroundColor = 'none';
            else
                obj.textBackgroundColor = endc(index - 1,:);
            end
            
        case 'cdata'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the object
            obj.cData(obj.index,:) = endc(index,:);
            
        case 'textcolor'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the object
            obj.textColor = endc(index,:);   
            
        case 'textedgecolor'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the object
            if index == 1
                obj.textEdgeColor = 'none';
            else
                obj.textEdgeColor = endc(index - 1,:);
            end
            
        case 'fontangle'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the object
            obj.fontAngle = selected;
            
        case 'fontsize'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected font size must be a number greater then 0.')
                return
            end
            
            % Update the object
            obj.fontSize = selected;
            
        case 'fontweight'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the object
            obj.fontWeight = selected;
            
        case 'horizontalalignment'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the object
            obj.horizontalAlignment = selected;
            
        case 'interpreter'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the object
            obj.interpreter = selected;
            
        case 'linestyle'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the object
            obj.lineStyle = selected;
            
        case 'linewidth'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected line width must be a number greater then 0.')
                return
            end
            
            % Update the object
            obj.lineWidth = selected;
            
        case 'positionx'
            
            string                   = get(hObject,'string');
            selected                 = str2double(string);
            obj.positionX(obj.index) = nb_conditional(isempty(selected),nan,selected);

        case 'positiony'
            
            string                   = get(hObject,'string');
            selected                 = str2double(string);
            obj.positionY(obj.index) = nb_conditional(isempty(selected),nan,selected);  
            
        case 'textlinewidth'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected line width must be a number greater then 0.')
                return
            end
            
            % Update the object
            obj.textLineWidth = selected;  
            
        case 'textmargin'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected margin must be a number greater then 0.')
                return
            end
            
            % Update the object
            obj.textMargin = selected;
            
        case 'textrotation'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) 
                nb_errorWindow('The selected font size must be a number.')
                return
            end
            
            % Update the object
            obj.textRotation = selected;
            
        case 'string'
            
            % Get the value selected
            string   = get(hObject,'string');
            
            % Update the object
            obj.string{obj.index} = string;
            
        case 'verticalalignment'
            
           % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the object
            obj.verticalAlignment = selected;
            
            
    end
    
    update(obj);
    notify(obj,'annotationEdited')

end

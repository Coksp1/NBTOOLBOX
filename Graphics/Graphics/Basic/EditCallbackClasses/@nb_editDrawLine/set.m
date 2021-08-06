function set(gui,hObject,~,type)
% Callback function for setting properties of the text box

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj = gui.parent;

    switch lower(type)
        
        case 'cdata'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the object
            obj.cData = endc(index,:);
            
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
            
        case 'side'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            obj.side = string{index};
            
        case 'units'
            
            % Update the object
            string    = get(hObject,'string');
            index     = get(hObject,'value');
            obj.units = string{index};
            if strcmpi(obj.units,'data')
                set(gui.sideHandle,'enable','on')
            else
                set(gui.sideHandle,'enable','on')
            end
            
    end
    
    update(obj);
    notify(obj,'annotationEdited')

end

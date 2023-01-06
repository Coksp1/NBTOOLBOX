function set(gui,hObject,~,type)
% Callback function for setting properties of the text box

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    annh = gui.parent;

    switch lower(type)
        
        case 'color'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the nb_barAnnotation object (and its children)
            annh.color = endc(index,:);
            textH      = annh.children;
            set(textH,'color',endc(index,:));
            
        case 'fontsize'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected font size must be a number greater then 0.')
                return
            end
            
            % Update the nb_barAnnotation object (and its children)
            annh.fontSize = selected;
            
            % If the font size is normalized we get the font size
            % transformed to another units
            %------------------------------------------------------
            if strcmpi(annh.fontUnits,'normalized')

                if strcmpi(annh.normalized,'axes')
                    fontS = annh.fontSize;
                else % figure
                    fontS = annh.fontSize*0.8/annh.parent.position(4);
                end

            else
                fontS = annh.fontSize;
            end
            
            % Assign the MATLAB text object
            textH = annh.children;
            set(textH,'fontSize',fontS);
            
        case 'fontweight'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_barAnnotation object (and its children)
            annh.fontWeight = selected;
            textH           = annh.children;
            set(textH,'fontWeight',selected);
            
        case 'rotation'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) 
                nb_errorWindow('The selected font size must be a number.');
                return
            end
            
            % Update the nb_barAnnotation object (and its children)
            annh.rotation = selected;
            textH         = annh.children;
            set(textH,'rotation',selected);
            
%         case 'string'
%             
%             % Get the value selected
%             string   = get(hObject,'string');
%             
%             % Update the nb_barAnnotation object (and its children)
%             annh.string = string;
%             textH       = annh.children(1);
%             set(textH,'string',string);
            
        case 'location'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_barAnnotation object
            annh.set('location',selected);
            
       case 'force'
            
            % Get the value selected
            value    = get(hObject,'value');
            
            % Update the nb_barAnnotation object
            annh.set('force',value);  
            
      case 'decimals'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = round(str2double(string));
            
            if isnan(selected) || selected < 0
                nb_errorWindow('The selected number of decimals must be a number greater then or equal to 0.')
                return
            end
            
            % Update the nb_barAnnotation object
            annh.set('decimals',selected);
            
      case 'space'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected space must be a number greater then 0.')
                return
            end
            
            % Update the nb_barAnnotation object
            annh.set('space',selected);      
                
            
    end
    
    notify(annh,'annotationEdited')

end

function set(gui,hObject,~,type)
% Callback function for setting properties of the text box

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    textBox = gui.parent;

    switch lower(type)
        
        case 'backgroundcolor'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the nb_textBox object (and its children)
            if index == 1
                color                   = 'none';
                textBox.backgroundColor = color;
            else
                textBox.backgroundColor = endc(index - 1,:);
                color                   = endc(index - 1,:);
            end
            textH = textBox.children(1);
            set(textH,'backgroundcolor',color);
            
        case 'color'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the nb_textBox object (and its children)
            textBox.color = endc(index,:);
            textH = textBox.children(1);
            set(textH,'color',endc(index,:));
            
        case 'edgecolor'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the nb_textBox object (and its children)
            if index == 1
                color             = 'none';
                textBox.edgeColor = color;
            else
                textBox.edgeColor = endc(index - 1,:);
                color             = endc(index - 1,:);
            end
            textH = textBox.children(1);
            set(textH,'edgeColor',color);
            
        case 'fontangle'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            textBox.fontAngle = selected;
            textH = textBox.children(1);
            set(textH,'fontAngle',selected);
            
        case 'fontsize'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected font size must be a number greater then 0.')
                return
            end
            
            % Update the nb_textBox object (and its children)
            textBox.fontSize = selected;
            
            % If the font size is normalized we get the font size
            % transformed to another units
            %------------------------------------------------------
            if strcmpi(textBox.fontUnits,'normalized')

                if strcmpi(textBox.normalized,'axes')
                    fontS = textBox.fontSize;
                else % figure
                    fontS = textBox.fontSize*0.8/textBox.parent.position(4);
                end

            else
                fontS = textBox.fontSize;
            end
            
            % Assign the MATLAB text object
            textH = textBox.children(1);
            set(textH,'fontSize',fontS);
            
        case 'fontweight'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            textBox.fontWeight = selected;
            textH = textBox.children(1);
            set(textH,'fontWeight',selected);
            
        case 'horizontalalignment'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            textBox.horizontalAlignment = selected;
            textH = textBox.children(1);
            set(textH,'horizontalAlignment',selected);
            
        case 'interpreter'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            textBox.interpreter = selected;
            textH = textBox.children(1);
            set(textH,'interpreter',selected);
            
        case 'linestyle'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            textBox.lineStyle = selected;
            textH = textBox.children(1);
            set(textH,'lineStyle',selected);
            
        case 'linewidth'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected line width must be a number greater then 0.')
                return
            end
            
            % Update the nb_textBox object (and its children)
            textBox.lineWidth = selected;
            textH = textBox.children(1);
            set(textH,'lineWidth',selected);
            
        case 'margin'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected margin must be a number greater then 0.')
                return
            end
            
            % Update the nb_textBox object (and its children)
            textBox.margin = selected;
            textH = textBox.children(1);
            set(textH,'margin',selected);
            
        case 'rotation'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) 
                nb_errorWindow('The selected rotation must be a number.')
                return
            end
            
            % Update the nb_textBox object (and its children)
            textBox.rotation = selected;
            textH = textBox.children(1);
            set(textH,'rotation',selected);
            
        case 'side'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            if ~strcmpi(textBox.side,selected)
                
                textBox.side = selected;
                
                % Get the new coordinates
                ax = textBox.parent;
                yy = textBox.yData;
                if strcmpi(selected,'left') 
                    yy = nb_pos2pos(yy,ax.yLimRight,ax.yLim,ax.yScaleRight,ax.yScale); 
                else % right
                    yy = nb_pos2pos(yy,ax.yLim,ax.yLimRight,ax.yScale,ax.yScaleRight); 
                end
                textBox.yData = yy;
                
            end
            
        case 'string'
            
            % Get the value selected
            string   = get(hObject,'string');
            
            % Update the nb_textBox object (and its children)
            textBox.string = string;
            textH = textBox.children(1);
            set(textH,'string',string);
            
        case 'units'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            if ~strcmpi(textBox.units,selected)
                
                textBox.units = selected;
            
                % Get the new coordinates
                ax = textBox.parent;
                xx = textBox.xData;
                yy = textBox.yData;

                if strcmpi(selected,'normalized')
                    
                    % Find the text location in normalized units
                    %------------------------------------------------------
                    xx = nb_pos2pos(xx,ax.xLim,[0,1],ax.xScale,'normal'); 

                    if strcmpi(textBox.side,'right')
                        yy = nb_pos2pos(yy,ax.yLimRight,[0,1],ax.yScaleRight,'normal'); 
                    else
                        yy = nb_pos2pos(yy,ax.yLim,[0,1],ax.yScale,'normal'); 
                    end
                    enable = 'off';
                    
                else % data
                    
                    % Find the text location in data units
                    %------------------------------------------------------
                    xx = nb_pos2pos(xx,[0,1],ax.xLim,'normal',ax.xScale); 

                    if strcmpi(textBox.side,'right')
                        yy = nb_pos2pos(yy,[0,1],ax.yLimRight,'normal',ax.yScaleRight); 
                    else
                        yy = nb_pos2pos(yy,[0,1],ax.yLim,'normal',ax.yScale); 
                    end
                    enable = 'on';
                    
                end
                
                textBox.xData = xx;
                textBox.yData = yy;
                
                % Enable/disable the
                set(gui.sideHandle,'enable',enable);
                
            end
            
        case 'verticalalignment'
            
           % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            textBox.verticalAlignment = selected;
            textH = textBox.children(1);
            set(textH,'verticalAlignment',selected); 
            
    end
    
    notify(textBox,'annotationEdited')

end

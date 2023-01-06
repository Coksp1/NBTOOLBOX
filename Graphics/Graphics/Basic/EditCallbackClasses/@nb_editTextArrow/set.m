function set(gui,hObject,~,type)
% Callback function for setting properties of the text box

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj = gui.parent;

    switch lower(type)
        
        case 'headlength'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected head 1 length must be a number greater then 0.')
                return
            end
            
            % Update the object (and its children)
            obj.headLength = selected;
            h = obj.children(1);
            set(h,'headlength',selected);
            
        case 'headstyle'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the object (and its children)
            obj.headStyle = selected;
            h = obj.children(1);
            set(h,'headStyle',selected);
            
        case 'headwidth'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected head 1 width must be a number greater then 0.')
                return
            end
            
            % Update the object (and its children)
            obj.headWidth = selected;
            h = obj.children(1);
            set(h,'headWidth',selected);
            
        case 'textbackgroundcolor'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the nb_textBox object (and its children)
            if index == 1
                color                   = 'none';
                obj.textBackgroundColor = color;
            else
                obj.textBackgroundColor = endc(index - 1,:);
                color                   = endc(index - 1,:);
            end
            textH = obj.children(2);
            set(textH,'backgroundcolor',color);
            
        case 'color'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the nb_textBox object (and its children)
            obj.color = endc(index,:);
            h = obj.children(1);
            set(h,'color',endc(index,:));
            
        case 'textcolor'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the nb_textBox object (and its children)
            obj.textColor = endc(index,:);
            hText = obj.children(2);
            set(hText,'color',endc(index,:));    
            
        case 'textedgecolor'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the nb_textBox object (and its children)
            if index == 1
                color             = 'none';
                obj.textEdgeColor = color;
            else
                obj.textEdgeColor = endc(index - 1,:);
                color             = endc(index - 1,:);
            end
            textH = obj.children(2);
            set(textH,'edgeColor',color);
            
        case 'fontangle'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            obj.fontAngle = selected;
            textH = obj.children(2);
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
            obj.fontSize = selected;
            
            % If the font size is normalized we get the font size
            % transformed to another units
            %------------------------------------------------------
            if strcmpi(obj.fontUnits,'normalized')

                if strcmpi(obj.normalized,'axes')
                    fontS = obj.fontSize;
                else % figure
                    fontS = obj.fontSize*0.8/obj.parent.position(4);
                end

            else
                fontS = obj.fontSize;
            end
            
            % Assign the MATLAB text object
            textH = obj.children(2);
            set(textH,'fontSize',fontS);
            
        case 'fontweight'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            obj.fontWeight = selected;
            textH = obj.children(2);
            set(textH,'fontWeight',selected);
            
        case 'horizontalalignment'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            obj.horizontalAlignment = selected;
            
            % If the 'default' is selected, we need to calaculate 
            % the best alignment
            if strcmpi(selected,'default')
                h            = obj.children(1);
                xx           = get(h,'x');
                yy           = get(h,'y');
                [selected,~] = nb_textArrow.textAlignment(selected,'',xx,yy);
            end
            textH = obj.children(2);
            set(textH,'horizontalAlignment',selected);
            
        case 'interpreter'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            obj.interpreter = selected;
            textH = obj.children(2);
            set(textH,'interpreter',selected);
            
        case 'linestyle'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            obj.lineStyle = selected;
            h = obj.children(1);
            set(h,'lineStyle',selected);
            
        case 'linewidth'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected line width must be a number greater then 0.')
                return
            end
            
            % Update the nb_textBox object (and its children)
            obj.lineWidth = selected;
            h = obj.children(1);
            set(h,'lineWidth',selected);
            
        case 'textlinewidth'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected line width must be a number greater then 0.')
                return
            end
            
            % Update the nb_textBox object (and its children)
            obj.textLineWidth = selected;
            hText = obj.children(2);
            set(hText,'lineWidth',selected);    
            
        case 'textmargin'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected margin must be a number greater then 0.')
                return
            end
            
            % Update the nb_textBox object (and its children)
            obj.textMargin = selected;
            textH = obj.children(2);
            set(textH,'margin',selected);
            
        case 'textrotation'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) 
                nb_errorWindow('The selected font size must be a number.')
                return
            end
            
            % Update the nb_textBox object (and its children)
            obj.textRotation = selected;
            textH = obj.children(2);
            set(textH,'rotation',selected);
            
        case 'side'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            if ~strcmpi(obj.side,selected)
                
                obj.side = selected;
                
                % Get the new coordinates
                ax = obj.parent;
                yy = obj.yData;
                if strcmpi(selected,'left') 
                    yy = nb_pos2pos(yy,ax.yLimRight,ax.yLim,ax.yScaleRight,ax.yScale); 
                else % right
                    yy = nb_pos2pos(yy,ax.yLim,ax.yLimRight,ax.yScale,ax.yScaleRight); 
                end
                obj.yData = yy;
                
            end
            
        case 'string'
            
            % Get the value selected
            string   = get(hObject,'string');
            
            % Update the nb_textBox object (and its children)
            obj.string = string;
            textH = obj.children(2);
            set(textH,'string',string);
            
        case 'units'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            if ~strcmpi(obj.units,selected)
                
                obj.units = selected;
            
                % Get the new coordinates
                ax = obj.parent;
                xx = obj.xData;
                yy = obj.yData;

                if strcmpi(selected,'normalized')
                    
                    % Find the text location in normalized units
                    %------------------------------------------------------
                    xx = nb_pos2pos(xx,ax.xLim,[0,1],ax.xScale,'normal'); 

                    if strcmpi(obj.side,'right')
                        yy = nb_pos2pos(yy,ax.yLimRight,[0,1],ax.yScaleRight,'normal'); 
                    else
                        yy = nb_pos2pos(yy,ax.yLim,[0,1],ax.yScale,'normal'); 
                    end
                    enable = 'off';
                    
                else % data
                    
                    % Find the text location in data units
                    %------------------------------------------------------
                    xx = nb_pos2pos(xx,[0,1],ax.xLim,'normal',ax.xScale); 

                    if strcmpi(obj.side,'right')
                        yy = nb_pos2pos(yy,[0,1],ax.yLimRight,'normal',ax.yScaleRight); 
                    else
                        yy = nb_pos2pos(yy,[0,1],ax.yLim,'normal',ax.yScale); 
                    end
                    enable = 'on';
                    
                end
                
                obj.xData = xx;
                obj.yData = yy;
                
                % Enable/disable the
                set(gui.sideHandle,'enable',enable);
                
            end
            
        case 'verticalalignment'
            
           % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_textBox object (and its children)
            obj.verticalAlignment = selected;
            
            % If the 'default' is selected, we need to calaculate 
            % the best alignment
            if strcmpi(selected,'default')
                h            = obj.children(1);
                xx           = get(h,'x');
                yy           = get(h,'y');
                [~,selected] = nb_textArrow.textAlignment('',selected,xx,yy);
            end
            textH = obj.children(2);
            set(textH,'verticalAlignment',selected); 
            
    end
    
    notify(obj,'annotationEdited')

end

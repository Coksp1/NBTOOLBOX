function set(gui,hObject,~,type)
% Callback function for setting properties of the text box

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj = gui.parent;

    switch lower(type)
        
        case 'color'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the object (and its children)
            obj.color = endc(index,:);
            color     = endc(index,:);
            h         = obj.children(1);
            set(h,'color',color);
            
        case 'head1length'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected head 1 length must be a number greater then 0.')
                return
            end
            
            % Update the object (and its children)
            obj.head1Length = selected;
            h = obj.children(1);
            set(h,'head1length',selected);
            
        case 'head1style'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the object (and its children)
            obj.head1Style = selected;
            h = obj.children(1);
            set(h,'head1Style',selected);
            
        case 'head1width'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected head 1 width must be a number greater then 0.')
                return
            end
            
            % Update the object (and its children)
            obj.head1Width = selected;
            h = obj.children(1);
            set(h,'head1Width',selected);
            
        case 'head2length'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected head 2 length must be a number greater then 0.')
                return
            end
            
            % Update the object (and its children)
            obj.head2Length = selected;
            h = obj.children(1);
            set(h,'head2length',selected);    
            
        case 'head2style'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the object (and its children)
            obj.head2Style = selected;
            h = obj.children(1);
            set(h,'head2Style',selected); 
            
        case 'head2width'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected head 2 width must be a number greater then 0.')
                return
            end
            
            % Update the object (and its children)
            obj.head2Width = selected;
            h = obj.children(1);
            set(h,'head2Width',selected);    
               
        case 'linestyle'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the object (and its children)
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
            
            % Update the object (and its children)
            obj.lineWidth = selected;
            h = obj.children(1);
            set(h,'lineWidth',selected);
              
        case 'side'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the object (and its children)
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
            
        case 'units'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the nb_obj object (and its children)
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
              
    end
    
    notify(obj,'annotationEdited')

end

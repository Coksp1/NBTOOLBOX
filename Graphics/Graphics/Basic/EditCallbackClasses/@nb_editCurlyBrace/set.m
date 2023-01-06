function set(gui,hObject,~,type)
% Callback function for setting properties of the text box

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj = gui.parent;

    switch lower(type)
        
        case 'cdata'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the object (and its children)
            obj.cData = endc(index,:);
            color     = endc(index,:);
            h         = obj.children(1);
            set(h,'cData',color);
            
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
                    
                    % Find the location in normalized units
                    %------------------------------------------------------
                    xx = nb_pos2pos(xx,ax.xLim,[0,1],ax.xScale,'normal'); 

                    if strcmpi(obj.side,'right')
                        yy = nb_pos2pos(yy,ax.yLimRight,[0,1],ax.yScaleRight,'normal'); 
                    else
                        yy = nb_pos2pos(yy,ax.yLim,[0,1],ax.yScale,'normal'); 
                    end
                    enable = 'off';
                    
                else % data
                    
                    % Find the location in data units
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
                
                % Update the xData/yData
                set(gui.xdata1,'string',num2str(xx(1)));
                set(gui.xdata2,'string',num2str(xx(2)));
                set(gui.ydata1,'string',num2str(yy(1)));
                set(gui.ydata2,'string',num2str(yy(2)));
                
                % Enable/disable the
                set(gui.sideHandle,'enable',enable);
                
            end
            
        case 'width'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            if isnan(selected) || selected <= 0
                nb_errorWindow('The selected width must be a number greater then 0.')
                return
            end
            
            % Update the object (and its children)
            set(obj,'width',selected);
            
        case 'xdata1'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            if isnan(selected)
                nb_errorWindow('The selected X-Data(1) must be a number.')
                return
            end
            
            % Update the object (and its children)
            xData    = obj.xData;
            xData(1) = selected;
            set(obj,'xData',xData);
            
        case 'xdata2'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            if isnan(selected)
                nb_errorWindow('The selected X-Data(2) must be a number.')
                return
            end
            
            % Update the object (and its children)
            xData    = obj.xData;
            xData(2) = selected;
            set(obj,'xData',xData); 
            
        case 'ydata1'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            if isnan(selected)
                nb_errorWindow('The selected Y-Data(1) must be a number.')
                return
            end
            
            % Update the object (and its children)
            yData    = obj.yData;
            yData(1) = selected;
            set(obj,'yData',yData);
            
        case 'ydata2'
            
            % Get the value selected
            string   = get(hObject,'string');
            selected = str2double(string);
            if isnan(selected) 
                nb_errorWindow('The selected Y-Data(2) must be a number.')
                return
            end
            
            % Update the object (and its children)
            yData    = obj.yData;
            yData(2) = selected;
            set(obj,'yData',yData);
              
    end
    
    notify(obj,'annotationEdited')

end

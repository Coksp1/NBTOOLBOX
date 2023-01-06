function set(gui,hObject,~,type)
% Callback function for setting properties of the text box

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj = gui.parent;

    switch lower(type)
        
        case 'facecolor'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the object (and its children)
            if index == 1
                color         = 'none';
                obj.faceColor = color;
            else
                obj.faceColor = endc(index - 1,:);
                color         = endc(index - 1,:);
            end
            h = obj.children(1);
            set(h,'faceColor',color);
            
        case 'edgecolor'
            
            % Get the value selected
            endc  = gui.defaultColors;
            index = get(hObject,'value');
            
            % Update the object (and its children)
            h = obj.children(1);
            if index == 1
                color         = 'none';
                obj.edgeColor = 'none';
            elseif index == 2
                obj.edgeColor = 'same';
                color         = get(h,'faceColor');
            else
                obj.edgeColor = endc(index - 2,:);
                color         = endc(index - 2,:);
            end
            set(h,'edgeColor',color);
               
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
            
            % Update the position of the object
            if ~strcmpi(obj.side,selected)
                
                obj.side = selected;
                
                % Get the new coordinates
                ax  = obj.parent;
                pos = obj.position;
                
                if strcmpi(selected,'left') 
                    pos(2) = nb_pos2pos(pos(2),ax.yLimRight,ax.yLim,ax.yScaleRight,ax.yScale);
                    pos(4) = nb_dpos2dpos(pos(4),ax.yLimRight,ax.yLim,ax.yScaleRight,ax.yScale);
                else % right
                    pos(2) = nb_pos2pos(pos(2),ax.yLim,ax.yLimRight,ax.yScale,ax.yScaleRight);
                    pos(4) = nb_dpos2dpos(pos(4),ax.yLim,ax.yLimRight,ax.yScale,ax.yScaleRight);
                end
                obj.position = pos;
                
            end
            
        case 'units'
            
            % Get the value selected
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            % Update the object (and its children)
            if ~strcmpi(obj.units,selected)
                
                obj.units = selected;
            
                % Get the new coordinates
                ax  = obj.parent;
                pos = obj.position;
                xx  = pos(1);
                yy  = pos(2);
                ww  = pos(3);
                hh  = pos(4);

                if strcmpi(selected,'normalized')
                    
                    % Find the text location in normalized units
                    %------------------------------------------------------
                    xx = nb_pos2pos(xx,ax.xLim,[0,1],ax.xScale,'normal'); 
                    ww = nb_dpos2dpos(ww,ax.xLim,[0,1],ax.xScale,'normal');
                    
                    if strcmpi(obj.side,'right')
                        yy = nb_pos2pos(yy,ax.yLimRight,[0,1],ax.yScaleRight,'normal');
                        hh = nb_dpos2dpos(hh,ax.yLimRight,[0,1],ax.yScaleRight,'normal');
                    else
                        yy = nb_pos2pos(yy,ax.yLim,[0,1],ax.yScale,'normal');
                        hh = nb_dpos2dpos(hh,ax.yLim,[0,1],ax.yScale,'normal');
                    end
                    enable = 'off';
                    
                else % data
                    
                    % Find the text location in data units
                    %------------------------------------------------------
                    xx = nb_pos2pos(xx,[0,1],ax.xLim,'normal',ax.xScale); 
                    ww = nb_dpos2dpos(ww,[0,1],ax.xLim,'normal',ax.xScale);

                    if strcmpi(obj.side,'right')
                        yy = nb_pos2pos(yy,[0,1],ax.yLimRight,'normal',ax.yScaleRight);
                        hh = nb_dpos2dpos(hh,[0,1],ax.yLimRight,'normal',ax.yScaleRight); 
                    else
                        yy = nb_pos2pos(yy,[0,1],ax.yLim,'normal',ax.yScale);
                        hh = nb_dpos2dpos(hh,[0,1],ax.yLim,'normal',ax.yScale);
                    end
                    enable = 'on';
                    
                end
                
                obj.position = [xx,yy,ww,hh];
                
                % Enable/disable the
                set(gui.sideHandle,'enable',enable);
                
            end
              
    end
    
    notify(obj,'annotationEdited')

end

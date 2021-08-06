function plotLabel(obj,xx,yy,hh,xCor,yCor,string,format,class)

    % Test the color spcification
    if ischar(format.color)
        color = nb_plotHandle.interpretColor(format.color);
    else
        color = format.color;
    end
    if ischar(format.backgroundColor)
        backgroundColor = nb_plotHandle.interpretColor(format.backgroundColor);
    else
        backgroundColor = format.backgroundColor;
    end
    if ischar(format.edgeColor)
        edgeColor = nb_plotHandle.interpretColor(format.edgeColor);
    else
        edgeColor = format.edgeColor;
    end

    % If the font size is normalized we get the font size
    % transformed to another units
    if strcmpi(obj.fontUnits,'normalized')
        if strcmpi(obj.normalized,'axes')
            fontSize = format.fontSize;
        else % figure
            fontSize = format.fontSize*0.8/obj.parent.position(4);
        end
    else
        fontSize = format.fontSize;
    end

    % Plot the label
    t = text(xCor,yCor,string,...
          'backgroundColor',    backgroundColor,...   
          'clipping',           'off',...
          'color',              color,...
          'edgeColor',          edgeColor,...
          'fontName',           obj.fontName,...
          'fontWeight',         format.fontWeight,...
          'fontUnits',          obj.fontUnits,...
          'fontSize',           fontSize,...
          'horizontalAlignment',format.horizontalAlignment,...
          'interpreter',        format.interpreter,...
          'lineStyle',          format.lineStyle,...
          'lineWidth',          format.lineWidth,...
          'margin',             format.margin,...
          'parent',             obj.parent.axesLabelHandle,...
          'rotation',           format.rotation,...
          'tag',                class,...
          'verticalAlignment',  format.verticalAlignment,...
          'userData',           [xx,yy,hh]);

    obj.children = [obj.children,t];
    
    % Assign it a context menu
    cMenu = uicontextmenu('parent',obj.parent.parent.figureHandle); 
         eMenu = uimenu(cMenu,'Label','Edit');
            uimenu(eMenu,'Label','All','Callback',@obj.editCallback);
            uimenu(eMenu,'Label','Column','Callback',@obj.editCallback);
            uimenu(eMenu,'Label','Row','Callback',@obj.editCallback);
            uimenu(eMenu,'Label','Element','Callback',@obj.editCallback);
         uimenu(cMenu,'Label','Delete all','Callback',@obj.deleteCallback);
    set(eMenu,'userData',t);
    set(t,'UIContextMenu',cMenu)
                                          
end

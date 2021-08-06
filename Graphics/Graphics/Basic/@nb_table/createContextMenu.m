function createContextMenu(obj)

    if isempty(obj.defaultContextMenu)
        contextMenu = uicontextmenu();
        separator   = 'off';
    else
        contextMenu = obj.defaultContextMenu;
        separator   = 'on';
        child       = findobj(contextMenu,'Label','Format');
        if ishandle(child)
            delete(child);
        end
    end

    % Add
    addMenu = uimenu(contextMenu, 'Label', 'Add','separator',separator);
    uimenu(addMenu, 'Label', 'Add row above', 'Callback', {@obj.addRowCallback, 'above'});
    uimenu(addMenu, 'Label', 'Add row below', 'Callback', {@obj.addRowCallback, 'below'});
    uimenu(addMenu, 'Label', 'Add column before', 'Callback', {@obj.addColumnCallback, 'before'});
    uimenu(addMenu, 'Label', 'Add column after', 'Callback', {@obj.addColumnCallback, 'after'});
    
    % Delete
    deleteMenu = uimenu(contextMenu, 'Label', 'Delete');
    uimenu(deleteMenu, 'Label', 'Delete row', 'Callback', {@obj.deleteRowCallback});
    uimenu(deleteMenu, 'Label', 'Delete column', 'Callback', {@obj.deleteColumnCallback});

    % Format
    formatMenu = uimenu(contextMenu, 'Label', 'Format','separator','on');
    uimenu(formatMenu, 'Label', 'Cell...', 'Callback', {@obj.formatGUI, 'cell'});
    uimenu(formatMenu, 'Label', 'Row...', 'Callback', {@obj.formatGUI, 'row'});
    uimenu(formatMenu, 'Label', 'Column...', 'Callback', {@obj.formatGUI, 'column'});
    uimenu(formatMenu, 'Label', 'Table...', 'Callback', {@obj.formatGUI, 'table'});
    
    % Template
    templateMenu = uimenu(contextMenu, 'Label', 'Template');
    uimenu(templateMenu, 'Label', 'Default', 'Callback', @(varargin) templateCallback(obj, 'nb'));
    uimenu(templateMenu, 'Label', 'Latex', 'Callback', @(varargin) templateCallback(obj, 'latex'));
    uimenu(templateMenu, 'Label', 'None', 'Callback', @(varargin) templateCallback(obj, 'none'));
    uimenu(templateMenu, 'Label', 'Modify...', 'Enable', 'off');
    
    % Align
    formatMenu = uimenu(contextMenu, 'Label', 'Align','separator','on');
    uimenu(formatMenu, 'Label', 'Columns...', 'Callback', {@obj.alignGUI, 'columns'});
    uimenu(formatMenu, 'Label', 'Rows...', 'Callback', {@obj.alignGUI, 'rows'});
    
    % uimenu(contextMenu, 'Label', 'Create colormap', 'Callback', {@(varargin) obj.colormap});
    
    % Store needed handles
    obj.contextMenu         = contextMenu;
    obj.contextMenuAdd      = addMenu;
    obj.contextMenuDelete   = deleteMenu;
    obj.contextMenuFormat   = formatMenu;
    obj.contextMenuTemplate = templateMenu;
    
end

function templateCallback(obj, templateName)
    set(obj, 'stylingPatterns', nb_table.stylingPatternsTemplate(templateName));
    notify(obj,'tableStyleUpdate');
    obj.update();
end

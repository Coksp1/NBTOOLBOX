function graph(obj)
% Syntax:
% 
% graph(obj)
% 
% Description:
% 
% Plot the table
% 
% Input:
% 
% - obj : An object of class nb_table_data_source
% 
% Output:
%
% The table plotted on the screen.
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj  = obj(:); 
    nobj = size(obj,1);
    if nobj > 1
        for ii = 1:nobj
            graph(obj(ii));
        end
        return
    end

    %--------------------------------------------------------------
    % If the 'DB' property is empty there is no table to graph
    %--------------------------------------------------------------
    if isempty(obj.DB)  
        createEmptyTable(obj)      
        return;
    end
    
    %--------------------------------------------------------------
    % Adjust the font size
    %--------------------------------------------------------------
    oldFontSizes = scaleFontSize(obj);
    
    %------------------------------------------------------
    % Initialize the figures and set the figure properties
    %------------------------------------------------------
    if isempty(obj.figurePosition)
        inputs = {'name',obj.figureName,'color',obj.figureColor,'units','characters'};
    else
        inputs = {'name',obj.figureName,'color',obj.figureColor,'units','characters','position',obj.figurePosition};
    end

    if obj.manuallySetFigureHandle == 0
        if ~isempty(obj.plotAspectRatio)
            inputs = [inputs 'advanced',obj.advanced];
            obj.figureHandle = nb_graphPanel(obj.plotAspectRatio,inputs{:});
        else
            obj.figureHandle = nb_figure(inputs{:});
        end
    else
        if ~isempty(obj.axesHandle)
            if isvalid(obj.axesHandle)
                obj.axesHandle.deleteOption = 'all';
                delete(obj.axesHandle);
            end
        end
    end

    %------------------------------------------------------
    % Make the axes handle
    %------------------------------------------------------
    obj.axesHandle = nb_axes('parent',          obj.figureHandle,...
                             'position',        obj.position,...
                             'axisVisible',     'off');
    
    % Get the data of the table
    %-----------------------------------------------------
    dataAsCell = getDataAsCell(obj);
    dataAsCell = interpretDataMatrix(obj,dataAsCell); 
    if ~isa(obj,'nb_table_cell')
        dataAsCell{1,1} = '';
    end
    if numel(dataAsCell) > 500
        createEmptyTable(obj)  
        if isa(obj.parent,'nb_GUI')
            nb_errorWindow(['The selected range has too many elements to produce a table. '...
                            'Max number of elements are 500 (Is ' int2str(numel(dataAsCell)) '). '...
                            'Please shrink the window of the table.'])
        else
            warning('nb_table_data_source:MaxNumberOfElementsReached',['The selected range has too many elements '...
                    'to produce a table. Max number of elements are 500 (Is ' int2str(numel(dataAsCell)) '). Please '...
                    'shrink the window of the table.'])
        end
        return;
    end
    
    % UI context menu stuff
    %-----------------------------------------------------
    if isa(obj,'nb_table_cell')
        if isempty(obj.UIContextMenu)
            cMenu = uicontextmenu();
        else
            cMenu = obj.UIContextMenu;
        end
        if isempty(findobj(cMenu,'Label','Add'))
            addMenu = uimenu(cMenu,'Label','Add');
                uimenu(addMenu,'Label','Row...','Callback',@obj.add,'tag','row');
                uimenu(addMenu,'Label','Column...','Callback',@obj.add,'tag','column');
        end
    end
    
    %-----------------------------------------------------
    % Create the table
    %-----------------------------------------------------
    obj.table                = copy(obj.table);
    obj.table.updateOnChange = false;
    obj.table.language       = obj.language;
    set(obj.table,'String',                 dataAsCell,...
                  'allowDimensionChange',   false,...
                  'decimals',               obj.decimals,...
                  'Editing',                false,...
                  'fontName',               obj.fontName,...
                  'fontSize',               obj.fontSize,...
                  'fontUnits',              obj.fontUnits,...
                  'Parent',                 obj.axesHandle,...
                  'defaultContextMenu',     obj.UIContextMenu);
              
    obj.table.stylingPatterns = nb_table.stylingPatternsTemplate(obj.template);
    
    if ~isempty(obj.columnSpan)
        set(obj.table,'columnSpan',obj.columnSpan);
    end
    if ~isempty(obj.rowSpan)
        set(obj.table,'rowSpan',obj.rowSpan);
    end
    if ~isempty(obj.horizontalAlignment)
        set(obj.table,'horizontalAlignment',obj.horizontalAlignment);
    end
    if ~isempty(obj.columnSizes)
        set(obj.table,'columnSizes',obj.columnSizes);
    end
        
    % Then we plot it on screen
    plot(obj.table);
    
    % If the table notifies the nb_table_data_source object itself
    % notfies its listeners. I.e. trigger an updatedGraph event
    addlistener(obj.table,'tableUpdate',@obj.notifyUpdate);
    addlistener(obj.table,'tableStyleUpdate',@obj.notifyStyleUpdate);
    
    %--------------------------------------------------------------
    % Add annotations
    %--------------------------------------------------------------
    addAnnotation(obj);
    
    %--------------------------------------------------------------
    % Title of the plot if not the property 'noTitle' is set
    % to 1
    %--------------------------------------------------------------
    addTitle(obj);

    %--------------------------------------------------------------
    % Add the x-label, if not 'none'
    %--------------------------------------------------------------
    addXLabel(obj);
    
    %--------------------------------------------------------------
    % Add figure title and/or footer
    %--------------------------------------------------------------
    addAdvancedComponents(obj,obj.language);
    
    %--------------------------------------------------------------
    % Revert the font sizes
    %--------------------------------------------------------------
    revertFontSize(obj,oldFontSizes);
    
end

%==========================================================================
function createEmptyTable(obj)

    %---------------------------------------------------------- 
    % Initialize the figures and set the figure properties
    %----------------------------------------------------------
    if isempty(obj.figurePosition)
        inputs = {'name',obj.figureName,'color',obj.figureColor,'units','characters'};
    else
        inputs = {'name',obj.figureName,'color',obj.figureColor,'units','characters','position',obj.figurePosition};
    end

    if obj.manuallySetFigureHandle == 0
        if ~isempty(obj.plotAspectRatio)
            inputs = [inputs 'advanced',obj.advanced];
            obj.figureHandle = nb_graphPanel(obj.plotAspectRatio,inputs{:});
        else
            obj.figureHandle = nb_figure(inputs{:});
        end
    else
        if ~isempty(obj.axesHandle)
            if isvalid(obj.axesHandle)
                obj.axesHandle.deleteOption = 'all';
                delete(obj.axesHandle);
            end
        end
    end

    %----------------------------------------------------------
    % Make the axes handle
    %----------------------------------------------------------
    obj.axesHandle = nb_axes('parent',              obj.figureHandle(1),...
                             'position',            obj.position,...
                             'UIContextMenu',       obj.UIContextMenu,...
                             'axisVisible',         'off',...
                             'normalized',          obj.normalized); 

end

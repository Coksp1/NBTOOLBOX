function alignGUI(obj,~,~,type)
% Show align window

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the handle to the main program
    mainGUI = obj.gui;

    % Decide the window name 
    figName = ['Align ' type];

    % Create window
    figureHandle = nb_guiFigure(mainGUI,figName,[65,   15,  60,   30],'normal','off');
    
    % Make grid container object
    grid = nb_gridcontainer(figureHandle,...
        'Position',         [0 0 1 1],...
        'Margin',           10,...
        'GridSize',         [2, 1],...
        'VerticalWeight',   [0.9,0.1]);
    
    % Create table with legend options
    %--------------------------------------------------------------
    if strcmpi(type,'rows')
        tableData = obj.RowSizes';
    else
        tableData = obj.ColumnSizes';
    end
    if isempty(tableData)
        return
    else
        enable = 'on';
    end
    colNames = {type};
    colEdit  = true;
    colForm  = {'char'};
    table    = nb_uitable(grid,...
                    'units',                'normalized',...
                    'position',             [0 0 1 1],...
                    'data',                 tableData,...
                    'enable',               enable,...
                    'columnName',           colNames,...
                    'columnFormat',         colForm,...
                    'columnEdit',           colEdit);
    
    uicontrol(grid, nb_constant.BUTTON, ...
        'string',             'OK',...
        'callback',           {@okCallback,obj,table,type});
             
    set(figureHandle,'visible','on');
    
end

function okCallback(~, ~,obj,table,type)
        
    new  = get(table,'data')';
    newS = sum(new);
    new  = new./newS;
    if strcmpi(type,'rows')
        obj.RowSizes = new;
    else
        obj.ColumnSizes = new;
    end
    obj.update();
    set(table,'data',new');

end

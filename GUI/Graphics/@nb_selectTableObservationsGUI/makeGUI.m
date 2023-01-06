function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    parent  = gui.plotter.parent;

    if isa(gui.plotter,'nb_graph')
        string = 'Graph';
    else
        string = 'Table';
    end
    
    % Create the main window
    %--------------------------------------------------------------
    if isa(parent,'nb_GUI')
        name = [parent.guiName ': Set Page of ' string];
    else
        name = ['Set Page of ' string];
    end
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
               'units',          'characters',...
               'position',       [65   15  140   30],...
               'Color',          defaultBackground,...
               'name',           name,...
               'numberTitle',    'off',...
               'menuBar',        'None',...
               'toolBar',        'None',...
               'resize',         'off',...
               'windowStyle',    'modal');
    nb_moveFigureToMonitor(f,currentMonitor,'center');
    
    % Locations  
    %--------------------------------------------------------------
    ySpace       = 0.04;
    startList    = 0.1;
    vListHeight  = 1 - ySpace*2 - startList;
    startListX1  = 0.04;
    listWidth    = 0.4;
    startListX2  = 1 - startListX1 - listWidth;
    space        = startListX2 - startListX1 - listWidth;
    buttonSize   = 0.06;

    switch lower(gui.type)
        
        case 'variables'
            
            setSpecial(gui.plotter,'returnLocal',1);
            included   = gui.plotter.variablesOfTable;
            setSpecial(gui.plotter,'returnLocal',0);
            selectFrom = gui.plotter.DB.variables;
            helpString = '*If empty default selection is used';
            
        case 'types'
            
            setSpecial(gui.plotter,'returnLocal',1);
            included   = gui.plotter.typesOfTable;
            setSpecial(gui.plotter,'returnLocal',0);
            selectFrom = gui.plotter.DB.types;
            helpString = '*If empty default selection is used';
            
        case 'observations'
            
            included   = gui.plotter.observationsOfTable;
            selectFrom = observations(gui.plotter.DB);
            selectFrom = nb_double2cell(selectFrom,'%.0f');
            helpString = '*If empty start and end observations are used';
            
        case 'dates'
            
            included   = gui.plotter.datesOfTable;
            selectFrom = dates(gui.plotter.DB);
            helpString = '*If empty start and end dates are used';
            
    end
    
    % Plotted variable list
    %--------------------------------------------------------------
    uicontrol(...
                   'units',       'normalized',...
                   'position',    [startListX1, startList + vListHeight, listWidth, 0.04],...
                   'parent',      f,...
                   'style',       'text',...
                   'string',      'Select from:'); 

    varList = uicontrol('units',   'normalized',...
                     'position',    [startListX1, startList, listWidth, vListHeight],...
                     'parent',      f,...
                     'background',  [1 1 1],...
                     'style',       'listbox',...
                     'string',      selectFrom,...
                     'max',         length(selectFrom)); 

    % Included variable list 
    %--------------------------------------------------------------
    uicontrol(...
                   'units',       'normalized',...
                   'position',    [startListX2, startList + vListHeight, listWidth, 0.04],...
                   'parent',      f,...
                   'style',       'text',...
                   'string',      'Included*:'); 

    selList = uicontrol(...
                     'units',       'normalized',...
                     'position',    [startListX2, startList, listWidth, vListHeight],...
                     'parent',      f,...
                     'background',  [1 1 1],...
                     'style',       'listbox',...
                     'string',      included,...
                     'max',         length(included)); 

    uicontrol(...
                   'units',       'normalized',...
                   'position',    [startListX2, startList - ySpace - 0.04, listWidth, 0.04],...
                   'parent',      f,...
                   'style',       'text',...
                   'string',      helpString);              
                 
    % Create add variable to selected button 
    %--------------------------------------------------------------
    posB1 = [startListX1 + listWidth + space/2 - buttonSize/2, startList + vListHeight/2 + vListHeight/10 - buttonSize/2, buttonSize, buttonSize];
    uicontrol(...
                   'units',       'normalized',...
                   'position',    posB1,...
                   'parent',      f,...
                   'style',       'pushbutton',...
                   'string',      '>',...
                   'callback',    {@select,gui,varList,selList}); 

    %  Create remove variable to selected button
    posB2 = [startListX1 + listWidth + space/2 - buttonSize/2, startList + vListHeight/2 - vListHeight/10 - buttonSize/2, buttonSize, buttonSize];
    uicontrol(...
                   'units',       'normalized',...
                   'position',    posB2,...
                   'parent',      f,...
                   'style',       'pushbutton',...
                   'string',      '<',...
                   'callback',    {@deSelect,gui,selList}); 

    % Make GUI visible
    set(f,'visible','on');

end

function select(~,~,gui,varList,selList)
        
    % Get selected variables
    indexT  = get(varList,'value');
    stringT = get(varList,'string');
    vars    = stringT(indexT);

    % Ensure no overlapping variables
    oldVars = get(selList,'string');
    if ~isempty(oldVars) 
        indexT   = ismember(vars,oldVars);
        newVars  = vars(~indexT);
        vars     = [newVars; oldVars];
    end

    % Update the list of the removed variables
    set(selList,'string',vars,'value',1,'max',length(vars));

    % Update the graph object (nb_graph_adv)
    switch lower(gui.type)
        case 'variables'
            gui.plotter.variablesOfTable = vars'; 
        case 'types'
            gui.plotter.typesOfTable = vars'; 
        case 'observations'
            gui.plotter.observationsOfTable = str2num(char(vars))';  %#ok<ST2NM>
        case 'dates'     
            gui.plotter.datesOfTable = vars';          
    end
    
    % Update the changed status
    notify(gui,'changedGraph')

end

function deSelect(~,~,gui,selList)

    % Get selected variables
    indexT     = get(selList,'value');
    stringT    = get(selList,'string');
    varsToDel  = stringT(indexT);

    % Find out which to keep
    indexT     = ismember(stringT,varsToDel);
    varsToKeep = stringT(~indexT);

    % Update the list of the selected variables
    if isempty(varsToKeep)
        set(selList,'string',varsToKeep);%,'value',[],'max',[]);
    else
        set(selList,'string',varsToKeep,'value',1,'max',length(varsToKeep));
    end

    % Update the graph object
    switch lower(gui.type)
        case 'variables'
            gui.plotter.variablesOfTable = varsToKeep'; 
        case 'types'
            gui.plotter.typesOfTable = varsToKeep'; 
        case 'observations'
            gui.plotter.observationsOfTable = str2num(char(varsToKeep))';  %#ok<ST2NM>
        case 'dates'     
            gui.plotter.datesOfTable = varsToKeep';          
    end
    
    % Update the changed status
    notify(gui,'changedGraph')

end

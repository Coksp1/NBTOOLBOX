function selectScatterVariables(gui,~,~)
% Syntax:
%
% selectScatterVariables(gui,hObject,event)
%
% Description:
%
% Part of DAG. Make dialog box to make the user able to select the 
% variables of the given scatter group
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the scatter group selected
    string     = get(gui.popupmenu1,'string');
    index      = get(gui.popupmenu1,'value');
    group      = string{index};
    plotterT   = gui.plotter;
    if strcmpi(gui.scatterSide,'left')           
        scaGroups = plotterT.scatterVariables;
    else
        scaGroups = plotterT.scatterVariablesRight;
    end
    ind        = find(strcmp(group,scaGroups),1);
    parent     = plotterT.parent;
    
    % Crate window
    if isa(parent,'nb_GUI')
        name = [parent.guiName ': Select Scatter Variables'];
    else
        name = 'Select Scatter Variables';
    end
    
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    mm = figure('visible',        'off',...
                'units',          'characters',...
                'position',       [45   10  75   25],...
                'name',           name,...
                'numberTitle',    'off',...
                'menuBar',        'None',...
                'windowStyle',    'modal',...
                'toolBar',        'None',...
                'color',          defaultBackground);
    nb_moveFigureToMonitor(mm,currentMonitor,'center');
    
    
    % Variables list 
    ySpace       = 0.04;
    startList    = 0.04;
    vListHeight  = 1 - ySpace*4;
    startListX1  = 0.04;
    listWidth    = 0.4;
    startListX2  = 1 - startListX1 - listWidth;
    space        = startListX2 - startListX1 - listWidth;
    buttonSize   = 0.06;

    % Stored variable list
    %--------------------------------------------------------------
    variablesToList = plotterT.DB.variables;

    uicontrol(...
                   'units',       'normalized',...
                   'position',    [startListX1, ySpace*2 + vListHeight, listWidth, 0.04],...
                   'parent',      mm,...
                   'style',       'text',...
                   'string',      'Variables'); 

    varList = uicontrol('units',       'normalized',...
                     'position',    [startListX1, ySpace, listWidth, vListHeight],...
                     'parent',      mm,...
                     'background',  [1 1 1],...
                     'style',       'listbox',...
                     'string',      variablesToList,...
                     'max',         size(variablesToList,2)); 

    % Selected variable list 
    %--------------------------------------------------------------
    uicontrol(...
                   'units',       'normalized',...
                   'position',    [startListX2, ySpace*2 + vListHeight, listWidth, 0.04],...
                   'parent',      mm,...
                   'style',       'text',...
                   'string',      'Selected'); 

    if strcmpi(gui.scatterSide,'left')           
        selVariables = plotterT.scatterVariables{ind + 1};
    else
        selVariables = plotterT.scatterVariablesRight{ind + 1};
    end
    selList = uicontrol(...
                     'units',       'normalized',...
                     'position',    [startListX2, startList, listWidth, vListHeight],...
                     'parent',      mm,...
                     'background',  [1 1 1],...
                     'style',       'listbox',...
                     'string',      selVariables); 

    % Create add variable to selected button 
    %--------------------------------------------------------------
    posB1 = [startListX1 + listWidth + space/2 - buttonSize/2, startList + vListHeight/2 + vListHeight/10 - buttonSize/2, buttonSize, buttonSize];
    uicontrol(...
                   'units',       'normalized',...
                   'position',    posB1,...
                   'parent',      mm,...
                   'style',       'pushbutton',...
                   'string',      '>',...
                   'callback',    {@select,gui,varList,selList}); 

    %  Create remove variable to selected button
    posB2 = [startListX1 + listWidth + space/2 - buttonSize/2, startList + vListHeight/2 - vListHeight/10 - buttonSize/2, buttonSize, buttonSize];
    uicontrol(...
                   'units',       'normalized',...
                   'position',    posB2,...
                   'parent',      mm,...
                   'style',       'pushbutton',...
                   'string',      '<',...
                   'callback',    {@deSelect,gui,selList}); 

    % Make visible
    set(mm,'visible','on');

end

%==================================================================
% SUB
%==================================================================

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

    % Update the list of the model variables
    set(selList,'string',sort(vars),'value',1,'max',length(vars));

    % Update the graph object
    stringT   = get(gui.popupmenu1,'string');
    indexT    = get(gui.popupmenu1,'value');
    groupT    = stringT{indexT};
    plotterTT = gui.plotter;
    if strcmpi(gui.scatterSide,'left')
        scaGroupsT = plotterTT.scatterVariables;
        property   = 'scatterVariables';
    else
        scaGroupsT = plotterTT.scatterVariablesRight;
        property   = 'scatterVariablesRight';
    end
    indT                 = find(strcmp(groupT,scaGroupsT),1);
    scaGroupsT{indT + 1} = vars;
    plotterTT.set(property, scaGroupsT);

    % Notify listeners
    %----------------------------------------------------------
    notify(gui,'changedGraph');

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
        nb_errorWindow('The number of selected variables cannot be zero.')
        return
    else
        set(selList,'string',varsToKeep,'value',1,'max',length(varsToKeep));
    end

    % Update the graph object
    stringT   = get(gui.popupmenu1,'string');
    indexT    = get(gui.popupmenu1,'value');
    groupT    = stringT{indexT};
    plotterTT = gui.plotter;
    if strcmpi(gui.scatterSide,'left')
        scaGroupsT = plotterTT.scatterVariables;
        property   = 'scatterVariables';
    else
        scaGroupsT = plotterTT.scatterVariablesRight;
        property   = 'scatterVariablesRight';
    end
    indT                 = find(strcmp(groupT,scaGroupsT),1);
    scaGroupsT{indT + 1} = varsToKeep;
    plotterTT.set(property, scaGroupsT);

    % Notify listeners
    %----------------------------------------------------------
    notify(gui,'changedGraph');

end

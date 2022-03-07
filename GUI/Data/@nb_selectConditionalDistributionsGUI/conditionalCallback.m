function conditionalCallback(gui,~,~)
% Syntax:
%
% conditionalCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Crate window
    %--------------------------------------------------------------
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    mm = figure('visible',        'off',...
                'units',          'characters',...
                'position',       [45   10  80   25],...
                'name',           'Hard condition on variables',...
                'numberTitle',    'off',...
                'menuBar',        'None',...
                'windowStyle',    'modal',...
                'toolBar',        'None',...
                'color',          defaultBackground);
    movegui(mm,'center');
    nb_moveFigureToMonitor(mm,currentMonitor);

    % Locations  
    %--------------------------------------------------------------
    ySpace       = 0.04;
    startList    = 0.1;
    vListHeight  = 1 - ySpace*3 - startList;
    startListX1  = 0.04;
    listWidth    = 0.4;
    startListX2  = 1 - startListX1 - listWidth;
    space        = startListX2 - startListX1 - listWidth;
    buttonSize   = 0.06;

    % Plotted variable list
    %--------------------------------------------------------------
    uicontrol(...
                   'units',       'normalized',...
                   'position',    [startListX1, startList + ySpace + vListHeight, listWidth, 0.04],...
                   'parent',      mm,...
                   'style',       'text',...
                   'string',      'Variables'); 

    varList = uicontrol(...
                     'units',       'normalized',...
                     'position',    [startListX1, startList, listWidth, vListHeight],...
                     'parent',      mm,...
                     'background',  [1 1 1],...
                     'style',       'listbox',...
                     'string',      gui.variables,...
                     'max',         size(gui.variables,2)); 

    % Conditional on variable list 
    %--------------------------------------------------------------
    uicontrol(...
                   'units',       'normalized',...
                   'position',    [startListX2, startList + ySpace + vListHeight, listWidth, 0.04],...
                   'parent',      mm,...
                   'style',       'text',...
                   'string',      'Selected'); 

    selList = uicontrol(...
                     'units',       'normalized',...
                     'position',    [startListX2, startList, listWidth, vListHeight],...
                     'parent',      mm,...
                     'background',  [1 1 1],...
                     'style',       'listbox',...
                     'string',      {}); 

    % Create add variable to selected button 
    %--------------------------------------------------------------
    posB1 = [startListX1 + listWidth + space/2 - buttonSize/2, startList + vListHeight/2 + vListHeight/10 - buttonSize/2, buttonSize, buttonSize];
    uicontrol(...
                   'units',       'normalized',...
                   'position',    posB1,...
                   'parent',      mm,...
                   'style',       'pushbutton',...
                   'string',      '>',...
                   'callback',    {@select,selList,varList}); 

    %  Create remove variable to selected button
    posB2 = [startListX1 + listWidth + space/2 - buttonSize/2, startList + vListHeight/2 - vListHeight/10 - buttonSize/2, buttonSize, buttonSize];
    uicontrol(...
                   'units',       'normalized',...
                   'position',    posB2,...
                   'parent',      mm,...
                   'style',       'pushbutton',...
                   'string',      '<',...
                   'callback',    {@deSelect,selList}); 

    % Pushbutton
    uicontrol(...
                   'units',       'normalized',...
                   'position',    [0.5 - 0.2/2,0.05-0.05/2,0.2,0.05],...
                   'parent',      mm,...
                   'style',       'pushbutton',...
                   'string',      'Finish',...
                   'callback',    {@finish,gui,selList}); 
               
               
    % Make GUI visible
    %--------------------------------------------------------------
    set(mm,'visible','on');

end

function select(~,~,selList,varList)
        
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
    set(selList,'string',sort(vars),'value',1,'max',length(vars));

end

function deSelect(~,~,selList)
        
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

end

function finish(~,~,gui,selList)

    % Get selected variables
    varsToDel = get(selList,'string');
    [~,ind]   = ismember(varsToDel,gui.variables);
    
    % Assign conditional value
    distr                    = gui.distributions(:,ind);
    m                        = num2cell(mean(distr));
    [distr.conditionalValue] = m{:};

    % Update table contents
    gui.addToHistory();
    gui.updateGUI();
    
end

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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the variables plotted
    %--------------------------------------------------------------
    plotterAdv = gui.plotter;
    vars       = {};
    for ii = 1:size(plotterAdv.plotter,2)
        vars = [vars,getPlottedVariables(plotterAdv.plotter(ii))]; %#ok<AGROW>
    end
    
    % Get the variables which is already removed
    %--------------------------------------------------------------
    removed = plotterAdv.remove;
    if isempty(vars)
        nb_errorWindow('It is not possible to remove a variable from the excel output when there are no variables to remove.')
        return
    end
    
    % Create window
    %--------------------------------------------------------------
    parent = plotterAdv.plotter(1).parent;
    mm     = nb_guiFigure(parent,'Remove Variables from Excel Output',[45   10  80   25],'modal');
    gui.figureHandle = mm;

    % Locations  
    %--------------------------------------------------------------
    ySpace       = 0.04;
    startList    = 0.04;
    vListHeight  = 1 - ySpace*4;
    startListX1  = 0.04;
    listWidth    = 0.4;
    startListX2  = 1 - startListX1 - listWidth;
    space        = startListX2 - startListX1 - listWidth;
    buttonSize   = 0.06;

    % Plotted variable list
    %--------------------------------------------------------------
    uicontrol(nb_constant.LABEL,...
        'position',    [startListX1, ySpace*2 + vListHeight, listWidth, 0.04],...
        'parent',      mm,...
        'string',      'Variables'); 

    gui.varList = uicontrol(nb_constant.LISTBOX,...
        'position',    [startListX1, ySpace, listWidth, vListHeight],...
        'parent',      mm,...
        'string',      vars,...
        'max',         size(vars,2)); 

    % Removed variable list 
    %--------------------------------------------------------------
    nb_uicontrolDAG(parent, nb_constant.LABEL,...
        'position',    [startListX2, ySpace*2 + vListHeight, listWidth, 0.04],...
        'parent',      mm,...
        'string',      'Remove',...
        'tooltip',     'Variables will not be exported to Excel. Use for data that cannot be published and help series!'); 

    gui.selList = uicontrol(nb_constant.LISTBOX,...
        'position',    [startListX2, startList, listWidth, vListHeight],...
        'parent',      mm,...
        'string',      removed); 

    % Create add variable to selected button 
    %--------------------------------------------------------------
    posB1 = [startListX1 + listWidth + space/2 - buttonSize/2, startList + vListHeight/2 + vListHeight/10 - buttonSize/2, buttonSize, buttonSize];
    uicontrol(nb_constant.BUTTON,...
       'position',    posB1,...
       'parent',      mm,...
       'string',      '>',...
       'callback',    @gui.select); 

    %  Create remove variable to selected button
    posB2 = [startListX1 + listWidth + space/2 - buttonSize/2, startList + vListHeight/2 - vListHeight/10 - buttonSize/2, buttonSize, buttonSize];
    uicontrol(nb_constant.BUTTON,...
       'position',    posB2,...
       'parent',      mm,...
       'string',      '<',...
       'callback',    @gui.deSelect); 

    % Make GUI visible
    %--------------------------------------------------------------
    set(mm,'visible','on');
          
end

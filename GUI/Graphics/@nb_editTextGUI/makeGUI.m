function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
%
% GUI window is being built sequentially. The makeGUI (this file) is the
% only constant once the user changes the graph. 
%
% makeGUI -> (changeGraph) -> addLeftColumnGUI -> addSingleFieldGUI
% -> (if panel:) addPanelGUI -> addUpdateButtonGUI (and display window)
% Note that all the subsequent GUIs are called from addLeftColumnGUI.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    % Coming from another session and importing a new one
    if ~isempty(gui.figureHandle)
        close(gui.figureHandle)
    end
    
    graphs     = gui.infoStruct;
    graphNames = fieldnames(gui.infoStruct);
    
    % Default graph
    if isempty(gui.graphObj)
        gui.graphObj = graphs.(graphNames{1});
        gui.name     = graphNames{1};
    end
    
    name = gui.name;
    f    = nb_guiFigure(gui.parent,name,[65  15  130   65],'normal','off');
    
    gui.figureHandle = f;
        
    % Position helpers
    startT       = 0.04;
    startOp      = 0.23;
    startDistBot = 0.97;
    numOp        = 0.05;
    heightT      = 0.053;
    heightEB     = 0.03;
    widthEB      = 0.26;
    delta        = 0.025;
    
    % Make menus
    opMenu = uimenu(f,'Label','Options');
    if ~isempty(gui.parent)
        uimenu(opMenu,'Label','Save to session','callback',@gui.saveToSession);
    end
        uimenu(opMenu,'Label','Export to .mat file','callback',@gui.exportTextStruct);
        uimenu(opMenu,'Label','Import from .mat file','callback',@gui.importTextStructCallback);
        uimenu(opMenu,'Label','Help','separator','on','callback',@gui.helpEditTextGUICallback);
        
    
    % Choose Figure
    uicontrol(...
          'units',                  'normalized',...
          'position',               [startT, startDistBot-numOp, 0.35, heightT],...
          'parent',                 f,...
          'style',                  'text',...
          'horizontalAlignment',    'left',...
          'fontWeight',             'bold',...
          'string',                 'Choose figure');
      
    gui.popup = uicontrol(...
          'units',                  'normalized',...
          'position',               [startOp, startDistBot-numOp+delta, widthEB, heightEB],...
          'parent',                 f,...
          'style',                  'popupmenu',...
          'horizontalAlignment',    'left',...
          'string',                 graphNames,...
          'callback',               @gui.changeGraph);  
      
    % Helpful text
    uicontrol(...
      'units',                  'normalized',...
      'position',               [startT, startDistBot-numOp*18, 0.35, heightT],...
      'parent',                 f,...
      'style',                  'text',...
      'horizontalAlignment',    'left',...
      'string',                 ['*) "Update" only saves changes to this window. See ',...
                                 '"Help" for more.']);

    % Pass on object to create rest of GUI
    addLeftColumnGUI(gui);
    
end

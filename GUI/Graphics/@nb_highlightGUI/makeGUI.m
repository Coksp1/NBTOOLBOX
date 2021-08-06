function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
%
% Creates the menu for selecting an area to highlight.
% With a graph open: Annotation > Highlighted Area
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    parent   = plotterT.parent;
    name     = 'Highlight Properties';

    % Create the main window
    %--------------------------------------------------------------
    f = nb_guiFigure(parent,name,[40   15  85.5   31.5],'modal','off');
    gui.figureHandle = f;
  
    % Find the coordinate parameters
    %-------------------------------------------------------------- 
    popWidth1 = 0.41;
    popHeight = 0.05;
    tHeight   = 0.04;
    startX    = 0.04;
    startY    = 0.85;

    % Select line object pop-up menu
    %------------------------------------------------------
    uicontrol('units',                  'normalized',...
              'position',               [startX, startY + popHeight, popWidth1, tHeight],...
              'parent',                 f,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Select Highlight Object'); 


    number = size(plotterT.highlight,2);   
    if number == 0
        objects = {' '};
    else
        objects = cell(1,number);
        for ii = 1:number
            objects{ii} = ['Highlight ' int2str(ii)];
        end
    end
    
    pop1 = uicontrol(...
              'units',          'normalized',...
              'position',       [startX, startY, popWidth1, popHeight],...
              'parent',         f,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'string',         objects,...
              'Interruptible',  'off',...
              'value',          1,...
              'tag',         	'left',...
              'callback',       @gui.changeHighlightObject); 
    gui.popupmenu1 = pop1;
    
    % Add/delete highlight objects
    %------------------------------------------------------
    bgWidth  = 0.2;
    bgHeight = popHeight;
    uicontrol(...
              'units',          'normalized',...
              'position',       [1 - popWidth1 - startX, startY, bgWidth, bgHeight],...
              'parent',         f,...
              'style',          'pushbutton',...
              'string',         'Add',...
              'Interruptible',  'off',...
              'callback',       @gui.addHighlightObject); 

    uicontrol(...
              'units',          'normalized',...
              'position',       [1 - popWidth1 - startX, startY - tHeight*3, bgWidth, bgHeight],...
              'parent',         f,...
              'style',          'pushbutton',...
              'string',         'Delete',...
              'Interruptible',  'off',...
              'callback',       @gui.deleteHighlightObject); 
            
    % Create the rest of the panel (Highlight options)
    %--------------------------------------------------------------
    updatePanel(gui,objects{1},1);

    % Make GUI visible 
    %--------------------------------------------------------------
    set(f,'visible','on');
          
end

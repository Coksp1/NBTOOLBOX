function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
%
% Creates the menu for exporting a single graph.
% With a graph open: File > Export.
% 
% Written by Kenneth Sæterhagen Paulsen
%
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isa(gui.plotter,'nb_graph_adv')
        parent = gui.plotter.plotter.parent;
        if isa(gui.plotter.plotter,'nb_table_data_source')
            string = 'Table';
        else
            string = 'Graph';
        end
    else
        parent = gui.plotter.parent;
        if isa(gui.plotter,'nb_table_data_source')
            string = 'Table';
        else
            string = 'Graph';
        end
    end
    name   = ['Export ' string];

    % Make main window
    %--------------------------------------------------------------    
    
    f = nb_guiFigure(parent,name,[40   15  90   20],'modal','off');    
    gui.figureHandle = f;          
    
    % Locations
    %--------------------------------------------------------------
    xSpace       = 0.04;
    ySpace       = 0.04;
    yStartP1     = 0.78;
    yHeightP1    = 1 - yStartP1 - ySpace;
    xWidthP1     = 1 - xSpace*2;
    buttonHeight = 0.09;
    buttonWidth  = 0.2;
    
    % File name/path panel
    %--------------------------------------------------------------
    uip = uipanel(...
        'parent',       f,...
        'units',        'normalized',...
        'position',     [xSpace,yStartP1,xWidthP1,yHeightP1],...
        'title',        'File Name/Path');
    
    xPanelSpace = 0.02;
    yPanelSpace = 0.15;
    xPanelEdit  = 0.7;
    gui.edit1 = uicontrol(...
              'units',                  'normalized',...
              'position',               [xPanelSpace, yPanelSpace, xPanelEdit, 1 - yPanelSpace*2],...
              'parent',                 uip,...
              'background',             [1 1 1],...
              'style',                  'edit',...
              'horizontalAlignment',    'left',...
              'string',                 '');
    
    uicontrol(...
              'units',          'normalized',...
              'position',       [xPanelEdit + xPanelSpace*2, yPanelSpace, 1 - xPanelEdit - xPanelSpace*3, 1 - yPanelSpace*2],...
              'parent',         uip,...
              'style',          'pushbutton',...
              'string',         'Browse',...
              'callback',       @gui.browse);
          
    % Options Panel
    %--------------------------------------------------------------
    uip = uipanel(...
        'parent',       f,...
        'units',        'normalized',...
        'position',     [xSpace,ySpace*2 + buttonHeight,xWidthP1,yStartP1 - ySpace*3 - buttonHeight],...
        'title',        'Options');
    
    % Panel locations
    startPopX = 0.3;
    widthPop  = 0.5;
    heightPop = 0.11;
    startTX   = 0.04;
    widthT    = 0.35 - startTX*2;
    heightT   = 0.106;
    kk        = 4;
    spaceYPop = (1 - heightPop*kk)/(kk + 1);
    extra     = -(heightPop - heightT)*5;
    
    % File Type
    %--------------------------------------------------------------
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'File Type');
   
    if isa(gui.plotter,'nb_graph_adv') || isa(gui.plotter,'nb_graph')
        
        if isa(gui.plotter,'nb_graph_adv')
            graphMethod = get(gui.plotter.plotter,'graphMethod');
        else 
            graphMethod = get(gui.plotter,'graphMethod');
        end
        
        if strcmpi(graphMethod,'graph')
            strings = {'Portable document format (*.pdf)',...
                       'Enhanced metafile (*.emf)',...
                       'Portable network format (*.png)',...
                       'Encapsulated postscript (*.eps)',...
                       'Joint Photographic Group (*.jpg)',...
                       'Scalable Vector Graphics (*.svg)',...
                       'MATLAB Object (*.mat)',...
                       'MATLAB fig file (*.fig)'};
        else
            strings = {'Portable document format (*.pdf)',...
                       'Enhanced metafile (*.emf)',...
                       'Portable network format (*.png)',...
                       'Encapsulated postscript (*.eps)',...
                       'Joint Photographic Group (*.jpg)',...
                       'Scalable Vector Graphics (*.svg)',...
                       ...'MATLAB Object (*.mat)',...
                       'MATLAB fig file (*.fig)'};
        end
        
    else
        strings = {'Portable document format (*.pdf)',...
                   'Enhanced metafile (*.emf)',...
                   'Portable network format (*.png)',...
                   'Encapsulated postscript (*.eps)',...
                   'Joint Photographic Group (*.jpg)',...
                   'Scalable Vector Graphics (*.svg)',...
                   'MATLAB Object (*.mat)',...
                   'MATLAB fig file (*.fig)'};
    end
    value   = 1;
    
    gui.pop1 = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',         uip,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'string',         strings,...
              'value',          value,....
              'callback',       @gui.fileTypeCallback);
    
    % Flip Page
    %--------------------------------------------------------------
    kk = kk - 1;
    nb_uicontrolDAG(parent,nb_constant.LABEL,...
              'position',  [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',    uip,...
              'string',    'Flip Page',...
              'tooltip',   sprintf(['Changes orientation so the graph is printed horizontally / vertically.\n',...
                                    'The default differs across computers.']));
    value   = 1;
    
    gui.rb1 = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',         uip,...
              'style',          'radiobutton',...
              'Interruptible',  'off',...
              'value',          value);
             
    % Append
    %--------------------------------------------------------------
    kk = kk - 1;
    nb_uicontrolDAG(parent, nb_constant.LABEL,...
              'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',   uip,...
              'string',   'Append',...
              'tooltip',  'Appends the exported figure to an already written PDF document.');
    value   = 0;
    
    gui.rb2 = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',         uip,...
              'style',          'radiobutton',...
              'Interruptible',  'off',...
              'value',          value);
          
    % Crop
    %--------------------------------------------------------------
    kk = kk - 1;
    nb_uicontrolDAG(parent, nb_constant.LABEL,...
              'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',   uip,...
              'string',   'Crop',...
              'tooltip',  sprintf(['Removes whitespace around the exported figure.\n',...
                                   'Will not remove title and footer of the figure.']));
    value   = 0;
    
    gui.rb3 = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',         uip,...
              'style',          'radiobutton',...
              'Interruptible',  'off',...
              'value',          value);
          
    % A4 portrait
    %--------------------------------------------------------------
    kk = kk + 2;
    nb_uicontrolDAG(parent, nb_constant.LABEL,...
              'position', [startPopX + widthPop/3, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',   uip,...
              'string',   'A4 portrait',...
              'tooltip',  'Will print the exported figure to an a4 page.');
    value   = 0;
    
    gui.rb4 = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX + widthPop/3 + startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop/5, heightPop],...
              'parent',         uip,...
              'style',          'radiobutton',...
              'Interruptible',  'off',...
              'value',          value,...
              'callback',       @gui.a4PortraitCallback);      
          
    % For PPT
    %--------------------------------------------------------------
    kk = kk - 1;
    nb_uicontrolDAG(parent,nb_constant.LABEL,...
              'position', [startPopX + widthPop/3, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',   uip,...
              'string',   'For PPT',...
              'tooltip',  'Enables manual cropping of figure. Format must be set to EMF.');
    value   = 0;
    
    gui.rb5 = uicontrol(nb_constant.RADIOBUTTON,...
              'enable',     'off',...
              'position',   [startPopX + widthPop/3 + startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop/5, heightPop],...
              'parent',     uip,...
              'value',      value,...
              'callback',   @gui.pptCallback);   
          
    % Manual positions when doing EMF
    %--------------------------------------------------------------
    kk = kk - 1;
    nb_uicontrolDAG(parent, nb_constant.LABEL,...
              'position', [startPopX + widthPop/3, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',   uip,...
              'string',   'Manual positions',...
              'tooltip',  sprintf(['Set the axes position to crop\n the image when saved to EMF for\n power point. ',...
                                  'In normalized units.\n [x,y,dx,dy]']));
    
    boxWidth    = 0.06;   
    boxAndSpace = 0.07;
    
    cropBox1 = uicontrol(nb_constant.EDIT,...
              'enable',     'off',...
              'position',   [startPopX + widthPop/3 + startPopX - boxAndSpace, heightPop*(kk-1) + spaceYPop*kk, boxWidth, heightPop],...
              'parent',     uip,...
              'string',     '0.1'); 
          
    cropBox2 = uicontrol(nb_constant.EDIT,...
              'enable',     'off',...
              'position',   [startPopX + widthPop/3 + startPopX, heightPop*(kk-1) + spaceYPop*kk, boxWidth, heightPop],...
              'parent',     uip,...
              'string',     '0.1'); 
          
    cropBox3 = uicontrol(nb_constant.EDIT,...
              'enable',     'off',...
              'position',   [startPopX + widthPop/3 + startPopX + boxAndSpace, heightPop*(kk-1) + spaceYPop*kk, boxWidth, heightPop],...
              'parent',     uip,...
              'string',     '0.8'); 
          
    cropBox4 = uicontrol(nb_constant.EDIT,...
              'enable',     'off',...
              'position',   [startPopX + widthPop/3 + startPopX + boxAndSpace*2, heightPop*(kk-1) + spaceYPop*kk, boxWidth, heightPop],...
              'parent',     uip,...
              'string',     '0.85'); 
          
    gui.cropBoxes = [cropBox1,cropBox2,cropBox3,cropBox4];   
          
    % OK button
    %--------------------------------------------------------------
    uicontrol(nb_constant.BUTTON,...
      'position',       [0.5 - xSpace/2 - buttonWidth, ySpace, buttonWidth, buttonHeight],...
      'parent',         f,...
      'string',         'OK',...
      'callback',       @gui.saveToFile);
  
    % Cancel button
    %--------------------------------------------------------------
    uicontrol(nb_constant.BUTTON,...
      'position',       [0.5 + xSpace/2, ySpace, buttonWidth, buttonHeight],...
      'parent',         f,...
      'string',         'Cancel',...
      'callback',       @gui.cancel);
  
   % Make it visible
   %---------------------------------------------------------------
   set(f,'visible','on');
          
end

function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    plotterAdv = gui.plotter;
    name       = 'Tooltip';
    
    % GUI window
    %--------------------------------------------------------------
    gui.figureHandle = nb_guiFigure(plotterAdv.plotter(1).parent,name,[65, 15, 100, 40],'modal','off');
    
    % Positions of UI components
    topSpace      = 0.08;          
    editBoxHeight = 0.3;
    editBoxXLoc   = 0.04;
    editBoxYLoc1  = 1 - topSpace - editBoxHeight;
    editBoxYLoc2  = 1 - topSpace*2 - editBoxHeight*2;
    textYLoc1     = 1 - topSpace;
    textYLoc2     = 1 - topSpace*2 - editBoxHeight;
    textYLoc3     = 1 - topSpace*3 - editBoxHeight*2;
    width         = 0.1;  
    
    % Norwegian
    %--------------------------------------------------------------
    uicontrol(nb_constant.LABEL,...
              'position', [editBoxXLoc, textYLoc1, 1 - editBoxXLoc*2, 0.04],...
              'parent',   gui.figureHandle,...
              'string',   'Norwegian');

    string = char(plotterAdv.tooltipNor);

    gui.editBox1 = uicontrol(nb_constant.EDIT,...
              'position', [editBoxXLoc, editBoxYLoc1, 1 - editBoxXLoc*2, editBoxHeight],...
              'parent',   gui.figureHandle,...
              'string',   string,...
              'max',      2); 
          
    % English
    %--------------------------------------------------------------
    uicontrol(nb_constant.LABEL,...
              'position', [editBoxXLoc, textYLoc2, 1 - editBoxXLoc*2, 0.04],...
              'parent',   gui.figureHandle,...
              'string',   'English');

    string = char(plotterAdv.tooltipEng);
    
    gui.editBox2 = uicontrol(nb_constant.EDIT,...
              'position', [editBoxXLoc, editBoxYLoc2, 1 - editBoxXLoc*2, editBoxHeight],...
              'parent',   gui.figureHandle,...
              'string',   string,...
              'max',      2);

       
    % Wrap footer option      
    uicontrol(nb_constant.LABEL,...
              'position', [editBoxXLoc, textYLoc3, width + 0.02, 0.04],...
              'parent',   gui.figureHandle,...
              'string',   'Wrap*');      

    value              = plotterAdv.footerWrapping;          
    gui.tooltipWrapping = uicontrol(nb_constant.RADIOBUTTON,...
              'position',  [editBoxXLoc + 0.08, textYLoc3 + 0.003, width*2, 0.04],...
              'parent',    gui.figureHandle,...
              'value',     value,...
              'string',    '',...
              'callback',  @gui.wrapCallback);

    % Brake text info
    if value 
        string = '*) Use // to force line break.';
    else
        string = '';
    end
    gui.wrapInfo = uicontrol(nb_constant.LABEL,...
              'position',  [editBoxXLoc, 0.01, width*4, 0.04],...
              'parent',    gui.figureHandle,...
              'string',    string);          

          
    % Update button      
    %-------------------------------------------------------------- 
    buttonHeight = 0.05;
    buttonWidth  = 0.2;
    buttonXLoc   = 0.5 - buttonWidth/2;
    buttonYLoc   = editBoxYLoc2/2 - buttonHeight/2;
    
    uicontrol(...
              'units',              'normalized',...
              'position',           [buttonXLoc, buttonYLoc, buttonWidth, buttonHeight],...
              'parent',             gui.figureHandle,...
              'style',              'pushbutton',...
              'Interruptible',      'off',...
              'horizontalAlignment','left',...
              'string',             'Update',...
              'callback',           @gui.setTooltipCallback);
    
    % Make visible
    %--------------------------------------------------------------
    set(gui.figureHandle,'visible','on');
          
end

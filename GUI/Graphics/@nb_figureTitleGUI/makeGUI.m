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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    plotterAdv = gui.plotter;
    if isa(plotterAdv.plotter,'nb_table_data_source')
        string = 'Table';
    else
        string = 'Figure';
    end
    
    if strcmpi(gui.type, 'excel')
        xl     = 'Excel';
        string = '';
    else
        xl = '';
    end
    
    % GUI window
    %--------------------------------------------------------------
    gui.figureHandle = nb_guiFigure(plotterAdv.plotter(1).parent,[xl, string ' Title'],[65, 15, 100, 40],'modal','off');
    
    % Positions of UI components
    topSpace      = 0.08;          
    editBoxHeight = 0.3;
    editBoxXLoc   = 0.04;
    editBoxYLoc1  = 1 - topSpace - editBoxHeight;
    editBoxYLoc2  = 1 - topSpace*2 - editBoxHeight*2;
    textYLoc1     = 1 - topSpace;
    textYLoc2     = 1 - topSpace*2 - editBoxHeight;
    textYLoc3     = 1 - topSpace*3 - editBoxHeight*2;
    xSpace        = 0.03;
    width         = 0.1;
    
    % Norwegian
    %--------------------------------------------------------------
    uicontrol(nb_constant.LABEL,...
              'position', [editBoxXLoc, textYLoc1, 1 - editBoxXLoc*2, 0.04],...
              'parent',   gui.figureHandle,...
              'string',   'Norwegian');
    
    if strcmpi(gui.type,'excel')      
        string = char(plotterAdv.plotter(plotterAdv.currentGraph).excelTitleNor);
    else
        string = char(plotterAdv.figureTitleNor);
    end
    
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
    
    if strcmpi(gui.type,'excel')       
        string = char(plotterAdv.plotter(plotterAdv.currentGraph).excelTitleEng);
    else
        string = char(plotterAdv.figureTitleEng);
    end    
    
    gui.editBox2 = uicontrol(nb_constant.EDIT,...
              'position', [editBoxXLoc, editBoxYLoc2, 1 - editBoxXLoc*2, editBoxHeight],...
              'parent',   gui.figureHandle,...
              'string',   string,...
              'max',      2);
    
    if ~strcmpi(gui.type,'excel')  
        
        % Placement option    
        uicontrol(nb_constant.LABEL,...
                  'position', [editBoxXLoc, textYLoc3, width + 0.02, 0.04],...
                  'parent',   gui.figureHandle,...
                  'string',   'Placement');      

        p       = plotterAdv.figureTitlePlacement;      
        strings = {'center','left','leftaxes','right'};
        value   = find(strcmpi(p,strings));
        if isempty(value)
            value = 1;
        end    

        gui.popupmenu = uicontrol(nb_constant.POPUP,...
                  'position', [editBoxXLoc + width + xSpace, textYLoc3, width*2, 0.04],...
                  'parent',   gui.figureHandle,...
                  'value',    value,...
                  'string',   strings); 

        % Wrap title option      
        uicontrol(nb_constant.LABEL,...
                  'position', [editBoxXLoc + width*3 + xSpace*2, textYLoc3, width + 0.02, 0.04],...
                  'parent',   gui.figureHandle,...
                  'string',   'Wrap*');      

        value                   = plotterAdv.figureTitleWrapping;          
        gui.figureTitleWrapping = uicontrol(nb_constant.RADIOBUTTON,...
                  'position',  [editBoxXLoc + width*4 + xSpace*3, textYLoc3, width*2, 0.04],...
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
    end
          
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
              'callback',           @gui.setFigureTitleCallback);
    
    % Make visible
    %--------------------------------------------------------------
    set(gui.figureHandle,'visible','on');
          
end

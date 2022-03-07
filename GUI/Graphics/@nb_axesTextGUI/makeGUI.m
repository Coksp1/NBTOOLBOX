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

    plotterT = gui.plotter;
    parent   = plotterT.parent;
    
    % Create the main window
    %------------------------------------------------------
    if strcmpi(gui.type,'title')
        string = 'Title';
    elseif strcmpi(gui.type,'xlabel')
        string = 'X-Axis Label';
    elseif strcmpi(gui.type,'ylabel')
        string = 'Left Y-Axis Label';
    else
        string = 'Right Y-Axis Label';
    end
    name = [string ' Properties'];
    
    gui.figureHandle = nb_guiFigure(parent,name,[40   15  85.5   15.75],'modal');
    
    startPopX = 0.3;
    widthPop  = 0.2;
    heightPop = 0.11;
    startTX   = 0.04;
    widthT    = 0.35 - startTX*2;
    heightT   = 0.106;
    kk        = 7;
    spaceYPop = (1 - heightPop*kk)/(kk + 1);
    extra     = -(heightPop - heightT)*5;
    
    % Text
    %--------------------------------------------------------------
    uicontrol(nb_constant.LABEL,...
              'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',   gui.figureHandle,...
              'string',   'Text');
   
    if strcmpi(gui.type,'title')
        string = plotterT.title;
    elseif strcmpi(gui.type,'xlabel')
        string = plotterT.xLabel;
    elseif strcmpi(gui.type,'ylabel')
        string = plotterT.yLabel;
    else
        string = plotterT.yLabelRight;
    end
    string = nb_multilined2line(string,' \\ ');
    
    uicontrol(nb_constant.EDIT,...
              'position', [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop*3, heightPop],...
              'parent',   gui.figureHandle,...
              'string',   string,...
              'callback', @gui.setText);
    
    % Font Size
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(nb_constant.LABEL,...
              'position',[startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',  gui.figureHandle,...
              'string',  'Font Size*');

    if strcmpi(gui.type,'title')
        string = plotterT.titleFontSize;
    elseif strcmpi(gui.type,'xlabel')
        string = plotterT.xLabelFontSize;
    elseif strcmpi(gui.type,'ylabel')
        string = plotterT.yLabelFontSize;
    else
        string = plotterT.yLabelFontSize;
    end
    string = num2str(string);
    
    uicontrol(nb_constant.EDIT,...
              'position',   [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',     gui.figureHandle,...
              'string',     string,...
              'callback',   @gui.setFontSize);

    % Font Weight
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(nb_constant.LABEL,...
              'position',[startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',  gui.figureHandle,...
              'string',  'Font Weight');

    if strcmpi(gui.type,'title')
        weight = plotterT.titleFontWeight;
    elseif strcmpi(gui.type,'xlabel')
        weight = plotterT.xLabelFontWeight;
    elseif strcmpi(gui.type,'ylabel')
        weight = plotterT.yLabelFontWeight;
    else
        weight = plotterT.yLabelFontWeight;
    end
    strings = {'normal','bold','light'};
    value   = find(strcmpi(weight,strings));
    if isempty(value)
        value = 1;
    end
    
    uicontrol(nb_constant.POPUP,...
              'position', [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',   gui.figureHandle,...
              'string',   strings,...
              'value',    value,....
              'callback', @gui.setFontWeight);

    % Font Interpreter
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(nb_constant.LABEL,...
              'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',   gui.figureHandle,...
              'string',   'Interpreter');

    if strcmpi(gui.type,'title')
        int = plotterT.titleInterpreter;
    elseif strcmpi(gui.type,'xlabel')
        int = plotterT.xLabelInterpreter;
    elseif strcmpi(gui.type,'ylabel')
        int = plotterT.yLabelInterpreter;
    else
        int = plotterT.yLabelInterpreter;
    end
    strings = {'none','tex','latex'};
    value   = find(strcmpi(int,strings));
    if isempty(value)
        value = 1;
    end
    
    uicontrol(nb_constant.POPUP,...
              'position', [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',   gui.figureHandle,...
              'string',   strings,...
              'value',    value,....
              'callback', @gui.setInterpreter);

    if strcmpi(gui.type,'title') || strcmpi(gui.type,'xlabel')   
        
        % Alignment
        %--------------------------------------------------------------
        kk = kk - 1;
        uicontrol(nb_constant.LABEL,...
                  'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',   gui.figureHandle,...
                  'string',   'Alignment');

        if strcmpi(gui.type,'title')
            a = plotterT.titleAlignment;
        else
            a = plotterT.xLabelAlignment;
        end
        strings = {'center','left','right'};
        value   = find(strcmpi(a,strings));
        if isempty(value)
            value = 1;
        end

        uicontrol(nb_constant.POPUP,...
                  'position', [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',   gui.figureHandle,...
                  'string',   strings,...
                  'value',    value,....
                  'callback', @gui.setAlignment);
        
        % Placement
        %--------------------------------------------------------------
        kk = kk - 1;
        uicontrol(nb_constant.LABEL,...
                  'position',[startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',  gui.figureHandle,...
                  'string',  'Placement');

        if strcmpi(gui.type,'title')
            p = plotterT.titlePlacement;
        else
            p = plotterT.xLabelPlacement;
        end
        strings = {'center','left','leftaxes','right'};
        value   = find(strcmpi(p,strings));
        if isempty(value)
            value = 1;
        end

        uicontrol(nb_constant.POPUP,...
                  'position', [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',   gui.figureHandle,...
                  'string',   strings,...
                  'value',    value,....
                  'callback', @gui.setPlacement);      
              
    end 
    
    if strcmpi(gui.type,'title')
        
        % Hide title
        %--------------------------------------------------------------
        kk = kk - 1;
        uicontrol(nb_constant.LABEL,...
                  'position',[startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',  gui.figureHandle,...
                  'string',  'Hide title');

        uicontrol(nb_constant.RADIOBUTTON,...
                  'position', [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',   gui.figureHandle,...
                  'value',    plotterT.noTitle,....
                  'callback', @gui.setNoTitle);     
              
    end
    
    % Template note 
    %--------------------------------------------------------------
    nb_graphSettingsGUI.addTemplateFootnote(gui.figureHandle,false,[0.75,0.07,0.22,0.23]);
          
    % Make GUI visible 
    %--------------------------------------------------------------
    set(gui.figureHandle,'visible','on');
    
end

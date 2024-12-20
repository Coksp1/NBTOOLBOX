function lookPanel(gui)
% Creates a panel for editing look properties  

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get graph object 
    obj = gui.parent;

    % Create panel
    %--------------------------------------------------------------
    uip = uipanel('parent',              gui.figureHandle,...
                  'title',               '',...
                  'visible',             'on',...
                  'borderType',          'none',... 
                  'units',               'normalized',...
                  'position',            [0.22, 0.02, 1 - 0.24, 0.96]); 
    gui.panelHandle1 = uip;
    
    startPopX = 0.4;
    widthPop  = 0.35;
    heightPop = 0.055;
    startTX   = 0.04;
    widthT    = startPopX - startTX*2;
    heightT   = 0.053;
    widthB    = 1 - startPopX - widthPop - startTX*2;
    startB    = startPopX + widthPop + startTX;
    kk        = 9;
    spaceYPop = (1 - heightPop*kk)/(kk+1);
    extra     = -(heightPop - heightT)*5;
    
    % Get the colors to choose from
    %--------------------------------------------------------------
    
    % Locate or give default color to the variable
    endc = gui.defaultColors;
  
    % Locate the selected face color in the color list
    colorTemp = obj.faceColor;
    if ischar(colorTemp)
        colorTemp = nb_plotHandle.interpretColor(colorTemp);
    elseif iscell(colorTemp)
        colorTemp = nb_plotHandle.interpretColor(colorTemp);
    end

    if strcmpi(colorTemp,'none')
        valueColorF = 1;
    else
        [~,valueColorF] = ismember(colorTemp,endc,'rows');
        if valueColorF == 0
            endc              = [endc;colorTemp];
            valueColorF       = size(endc,1);
            gui.defaultColors = endc;
        end
        valueColorF = valueColorF + 1;
    end
    
    % Locate the selected color in the color list
    colorTemp = obj.edgeColor;
    if ischar(colorTemp)
        colorTemp = nb_plotHandle.interpretColor(colorTemp);
    elseif iscell(colorTemp)
        colorTemp = nb_plotHandle.interpretColor(colorTemp);
    end

    if strcmpi(colorTemp,'none')
        valueColor = 1;
    elseif strcmpi(colorTemp,'same')
        valueColor = 2;
    else
        [~,valueColor] = ismember(colorTemp,endc,'rows');
        if valueColor == 0
            endc              = [endc;colorTemp];
            valueColor        = size(endc,1);
            gui.defaultColors = endc;
        end
        valueColor = valueColor + 2;
    end
    
    % Using html coding to get the background of the 
    % listbox colored  
    colors = nb_htmlColors(endc);
    
    % Face Color
    %--------------------------------------------------------------
    uicontrol('units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Face Color'); 

    colorsF = ['None';colors];
    
    pop1 = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',         uip,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'tag',            'first',...
              'string',         colorsF,...
              'value',          valueColorF,....
              'callback',       {@gui.set,'faceColor'});

    def1 = uicontrol(...
              'units',          'normalized',...
              'position',       [startB, heightPop*(kk-1) + spaceYPop*kk, widthB, heightPop],...
              'parent',         uip,...
              'style',          'pushbutton',...
              'Interruptible',  'off',...
              'busyAction',     'cancel',...
              'string',         'Define');    
    
    % Edge Color
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol('units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Edge Color'); 

    colorsE = ['None';'Same';colors];
    
    pop2 = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',         uip,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'tag',            'first',...
              'string',         colorsE,...
              'value',          valueColor,....
              'callback',       {@gui.set,'edgeColor'});

    def2 = uicontrol(...
              'units',          'normalized',...
              'position',       [startB, heightPop*(kk-1) + spaceYPop*kk, widthB, heightPop],...
              'parent',         uip,...
              'style',          'pushbutton',...
              'Interruptible',  'off',...
              'busyAction',     'cancel',...
              'string',         'Define'); 
       
    % Assign define color callbacks
    set(def1,'callback',{@nb_setDefinedColorAnnotation,gui,pop1,pop2})
    set(def2,'callback',{@nb_setDefinedColorAnnotation,gui,pop1,pop2})
          
    % Line Style
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Line Style');

    lineStyles = {'-','--',':','-.','none'};       
    value      = find(strcmpi(obj.lineStyle,lineStyles),1);

    uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',          uip,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'string',         lineStyles,...
              'value',          value,....
              'callback',       {@gui.set,'lineStyle'});
   
    % Line Width
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Line Width');

    uicontrol(...
              'units',                  'normalized',...
              'position',               [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',                 uip,...
              'background',             [1 1 1],...
              'style',                  'edit',...
              'horizontalAlignment',    'right',...
              'Interruptible',          'off',...
              'string',                 num2str(obj.lineWidth),...
              'callback',               {@gui.set,'lineWidth'});
               
end

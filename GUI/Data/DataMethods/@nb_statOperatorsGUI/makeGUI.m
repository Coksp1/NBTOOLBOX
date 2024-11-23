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

    % Decide the window name
    switch lower(gui.type)
        case 'std'   
            figName = 'Standard deviation';
        case 'mean'  
            figName = 'Average';
        case 'mode'  
            figName = 'Mode';
        case 'median'  
            figName = 'Median';
        case 'var'  
            figName = 'Variance';
        case 'min'  
            figName = 'Min';    
        case 'max'  
            figName = 'Max';    
    end
    
    % Create window
    f = nb_guiFigure(gui.parent,figName,[65,   15,  120,   30],'modal','off');
    gui.comp.figureHandle = f;
    
    % Create panels
    %--------------------------------------------------------------
    pSpace  = 0.02;
    pWidth1 = 0.65;
    pWidth2 = 1 - pWidth1 - pSpace*3;
    uip1 = uipanel(...
        'units',              'normalized',...
        'position',           [pSpace, pSpace, pWidth1, 1 - pSpace*2],...
        'parent',             f,...
        'title',              'Options');
    
    
    uip2 = uipanel(...
        'units',              'normalized',...
        'position',           [pSpace*2 + pWidth1, pSpace, pWidth2, 1 - pSpace*2],...
        'parent',             f,...
        'title',              'Select Variables');
    
    % Variables selection list
    %--------------------------------------------------------------
    num = size(gui.data.variables,2); 
    gui.comp.variables = uicontrol(...
      'units',              'normalized',...
      'position',           [0.02, 0.1, 0.96, 0.88],...
      'parent',             uip2,...
      'background',         [1 1 1],...
      'style',              'listbox',...
      'string',             gui.data.variables,...
      'max',                num,...
      'value',              1:num);
  
    gui.comp.all = uicontrol(...
              'units',          'normalized',...
              'position',       [0.02, 0.02, 0.5, 0.06],...
              'parent',         uip2,...
              'style',          'radiobutton',...
              'Interruptible',  'off',...
              'string',         'All',...
              'value',          0,...
              'callback',       @gui.allCallback);
    
    % Locations
    %--------------------------------------------------------------
    startPopX = 0.45;
    widthPop  = 0.525;
    heightPop = 0.06;
    startTX   = 0.06;
    widthT    = widthPop - startTX*2;
    heightT   = 0.0533;
%     widthB    = 1 - startPopX - widthPop - startTX*2;
%     startB    = startPopX + widthPop + startTX;
    kk        = 9; 
    spaceYPop = (1 - heightPop*kk)/(kk + 1);
    extra     = -(heightPop - heightT);
    
    % Dates
    %--------------------------------------------------------------
    if isa(gui.data,'nb_ts') || isa(gui.data,'nb_data')
        
        uicontrol(uip1,nb_constant.LABEL,...
          'position',[startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
          'string',  'Start obs');             

        gui.comp.start = uicontrol(uip1,nb_constant.EDIT,...
         'position', [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
         'string',   '');
        kk = kk - 1;  
    
        % End
        %--------------------------------------------------------------
        uicontrol(uip1,nb_constant.LABEL,...
          'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
          'string',   'End obs');             

        gui.comp.finish = uicontrol(uip1,nb_constant.EDIT,...
          'position', [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
          'string',   ''); 
        kk = kk - 1;  
        
    end
          
    % Dimension
    %--------------------------------------------------------------
    if isa(gui.data,'nb_ts') || isa(gui.data,'nb_data')
        dim = {'Observations','Variables','Pages'};
        u   = {1,2,3};
    else
        dim = {'Types','Variables','Pages'};
        u   = {1,2,3};
    end
    
    uicontrol(uip1,nb_constant.LABEL,...
      'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
      'string',   'Dimension');

    gui.comp.dim = uicontrol(uip1,nb_constant.POPUP,...
      'position', [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
      'string',   dim, 'userData', u, 'callback', @gui.dimCallback);
    kk = kk - 1;
    
    % Postfix
    %--------------------------------------------------------------
    uicontrol(uip1,nb_constant.LABEL,...
      'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
      'string',   'Postfix');

    gui.comp.postfix = uicontrol(uip1,nb_constant.EDIT,...
      'position', [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
      'string',   ['_' lower(gui.type)]);
    kk = kk - 1;
  
    % Handle nan
    %--------------------------------------------------------------
    uicontrol(uip1,nb_constant.LABEL,...
      'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
      'string',   'Handle nan');

    gui.comp.handleNaN = uicontrol(uip1,nb_constant.RADIOBUTTON,...
      'position', [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
      'value',    true);
    
    % Calculate button
    %--------------------------------------------------------------
    buttonHeight = 0.0667;
    buttonWidth  = 0.3;
    buttonXLoc   = 0.5 - buttonWidth/2;
    buttonYLoc   = (heightPop*(kk-1) + spaceYPop*kk)/2 - buttonHeight/2;
    
    uicontrol(uip1,nb_constant.BUTTON,...
      'position', [buttonXLoc, buttonYLoc, buttonWidth, buttonHeight],...
      'string',   'Calculate',...
      'callback', @gui.calculateCallback);      
          
    % Make GUI visible
    %--------------------------------------------------------------
    set(f,'visible','on');
    
end

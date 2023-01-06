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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the handle to the main program
    mainGUI = gui.parent;

    % Decide the window name
    switch lower(gui.type)
        case 'growth'   
            figName = 'Log difference';
        case 'egrowth'  
            figName = 'Growth';
        case 'pcn'
            figName = 'Log difference (%)';
        case 'epcn' 
            figName = 'Growth (%)';
        case 'sgrowth'
            figName = 'Smooth growth (%)';
            if gui.data.frequency ~= 12
               nb_errorWindow('You need monthly data to use this method.')
               return
            end
    end
    
    f = nb_guiFigure(mainGUI,figName,[65,   15,  120,   30],'modal','off');
    gui.figureHandle = f;
    
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
    gui.comp.variableList = uicontrol(uip2,nb_constant.LISTBOX,...
              'position',           [0.02, 0.1, 0.96, 0.88],...
              'string',             gui.data.variables,...
              'max',                num,...
              'value',              1:num);
    
    gui.comp.radioButton = uicontrol(...
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
    rPanel = nb_rowPanel(uip1);

    % Number of periods
    %--------------------------------------------------------------
    if strcmp(gui.type,'sgrowth')
        
        gui.comp.horizon = uicontrol(rPanel,nb_constant.POPUP,...
                'Title',   'Horizon',...
                'string',  {'1','2'});
     
    else    
    
        gui.comp.numberOfPeriods = uicontrol(rPanel,nb_constant.EDIT,...
                 'Title',     'Periods',...
                 'string',    '1');   
                     
    end
        
    % Postfix
    %--------------------------------------------------------------

    gui.comp.postFix = uicontrol(rPanel, nb_constant.EDIT,...
              'Title',              'Postfix',...
              'string',             ['_' lower(gui.type)]);               
     
    if isa(gui.data,'nb_ts')
        
        if gui.data.frequency <= 12      

            % Multiply by
            %--------------------------------------------------------------
            gui.comp.multi = uicontrol(rPanel,    nb_constant.POPUP,...
                              'Title',  'Multiply by',...
                              'string', {'1','2','4','12'},...
                              'value',  1);    

        end
        
    end
          
    % Calculate button
    %--------------------------------------------------------------
    buttonHeight = 0.0667;
    buttonWidth  = 0.3;
    buttonXLoc   = 0.5 - buttonWidth/2;
    buttonYLoc   = 0.3;
    
    uicontrol(rPanel, nb_constant.BUTTON,...
              'position',           [buttonXLoc, buttonYLoc, buttonWidth, buttonHeight],...
              'string',             'Calculate',...
              'callback',           @gui.calculateCallback);      
          
    % Make GUI visible
    %--------------------------------------------------------------
    set(f,'visible','on');
    
end

function makeGUI(gui)
% Create the main window  

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    %------------------------------------------------------
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f    = figure('visible',        'off',...
                  'units',          'characters',...
                  'position',       [40   15  85.5   31.5],...
                  'Color',          defaultBackground,...
                  'name',           'Text Box Properties',...
                  'numberTitle',    'off',...
                  'menuBar',        'None',...
                  'toolBar',        'None',...
                  'resize',         'off',...
                  'windowStyle',    'modal');               
    gui.figureHandle = f;
    nb_moveFigureToMonitor(f,currentMonitor,'center');

    % Set up panel
    uib = uibuttongroup('parent',              f,...
                        'title',               '',...
                        'background',          [1 1 1],...
                        'Interruptible',       'off',...
                        'units',               'normalized',...
                        'position',            [0.02 0.02 0.18 0.96],...
                        'SelectionChangeFcn',  @gui.changePanel); 

    uicontrol(...
        'units',       'normalized',...
        'position',    [0, 0.90, 1, 0.1],...
        'background',  [1 1 1],...   
        'parent',      uib,...
        'style',       'togglebutton',...
        'string',      'Text'); 
 
    uicontrol(...
        'units',       'normalized',...
        'position',    [0, 0.80, 1, 0.1],...
        'background',  [1 1 1],...   
        'parent',      uib,...
        'style',       'togglebutton',...
        'string',      'Box');             

    uicontrol(...
        'units',       'normalized',...
        'position',    [0, 0.70, 1, 0.1],...
        'background',  [1 1 1],...   
        'parent',      uib,...
        'style',       'togglebutton',...
        'string',      'General');             

    % Get the colors to select from
    getColorsSelected(gui);
    
    % Make sub-windows            
    textPanel(gui);
    boxPanel(gui);
    generalPanel(gui);
    
    % Set color def callbacks
    set(gui.colordef1,'callback',{@nb_setDefinedColorAnnotation,gui,gui.colorpop1,gui.colorpop2,gui.colorpop3});
    set(gui.colordef2,'callback',{@nb_setDefinedColorAnnotation,gui,gui.colorpop1,gui.colorpop2,gui.colorpop3});
    set(gui.colordef3,'callback',{@nb_setDefinedColorAnnotation,gui,gui.colorpop1,gui.colorpop2,gui.colorpop3});
    
    % Set the window visible            
    set(f,'visible','on');

end

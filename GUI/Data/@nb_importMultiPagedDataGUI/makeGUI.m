function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Generates a window where the user can either import an excel sheet 
% directly or customize. Creates an import window for excel sheets,  
% with seperate panels for advanced and simple imports. 
% 
% Written by Eyo I. Herstad and Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Create Window
    %--------------------------------------------------------------
    gui.importWindow = nb_guiFigure(gui.parent,gui.figureName,[50 40 130 40],'modal','off');
    pos              = get(gui.importWindow,'position');
    pos(1)           = 0;
    pos(2)           = 0;
    
    % Create panel for intial and advanced selection    
    %--------------------------------------------------------------
    gui.initSelectPanel = uipanel(...
                'visible',      'on',...
                'parent',       gui.importWindow,...
                'units',        'characters',...
                'position',     pos,...
                'borderType',   'none',...
                'title',        '');
                        
    % Populate initial panel
    %--------------------------------------------------------------

    % Create table    
    gui.initTable = nb_uitable(gui.initSelectPanel,...
        'units',       'normalized',...
        'position',    [0.05 0.15 0.65 0.65]);
    
    % Sheet list box
    uicontrol(gui.initSelectPanel,nb_constant.LABEL,...
        'position',   [0.75, 0.82, 0.1, 0.03],...
        'string',     'Select sheets:');
    
    % Read all sheets
    gui.allButton = uicontrol(gui.initSelectPanel,nb_constant.RADIOBUTTON,...
        'position',  [0.85, 0.82, 0.1, 0.03],...
        'string',    'All',...
        'value',     0,...
        'callback',  @gui.allCallback);
    
    gui.sheets = uicontrol(gui.initSelectPanel,nb_constant.LISTBOX,...
        'position',   [0.75 0.15 0.2 0.65],...
        'string',     gui.sheetList);
    
    % Positions    
    Height    = 0.05;
    Width     = 0.15;
    textWidth = 0.18;
    space     = 0.1;
    xStart    = (1 - Width*3 - space*2)/2;
    ySpace    = 0.05;
    
    % Sheet selection
    uicontrol(gui.initSelectPanel,nb_constant.LABEL,...
        'position', [space, 1-ySpace-Height-0.01, textWidth, Height],...
        'string',   'Select Sheet to view:');
                        
    gui.initSheetSelectBox = uicontrol(gui.initSelectPanel,nb_constant.POPUP,...
        'position',  [space+textWidth, 1-ySpace-Height, Width, Height],...
        'string',    gui.sheetList,...
        'callback',  @gui.selectBoxCallback);

    % Sort
    gui.sortButton = uicontrol(gui.initSelectPanel,nb_constant.RADIOBUTTON,...
        'position',[space + textWidth + Width + 0.06, 1-ySpace-Height, Width, Height],...
        'string',  'Sort',...
        'value',   0);                    
                           
    % Buttons    
    uicontrol(gui.initSelectPanel,nb_constant.BUTTON,...
         'position',    [xStart,ySpace,Width,Height],...
         'callback',    @gui.exitGUI,...
         'String',      'Cancel');
        
    uicontrol(gui.initSelectPanel,nb_constant.BUTTON,...
         'position',    [xStart + Width*2 + space*2,ySpace,Width,Height],...
         'callback',    @gui.finishCallback,...
         'String',      'Finish');  
                
    % Update table
    updateTable(gui); 
     
    % Make the GUI visible.
    %--------------------------------------------------------------
    set(gui.importWindow,'Visible','on');

end


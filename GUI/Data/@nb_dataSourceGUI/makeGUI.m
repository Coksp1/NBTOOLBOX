function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% % Creates Window and panels for source window.
%
% Written by Eyo I. Herstad

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isa(gui.data,'nb_modelDataSource')
        enable = 'off';
    else 
        if ~gui.data.isUpdateable
            nb_errorWindow('The dataset is not updateable, so no sources to display')
            delete(gui)
            return
        end
        enable = 'on';
    end

    % Create Window
    %--------------------------------------------------------------
    gui.sourceWindow = nb_guiFigure(gui.parent,gui.figureName,[50 40 80 30],'modal','off');
    
    yStart    = 0.9;
    xSpace    = 0.03;
    Height    = 0.05;
    textWidth = 0.15;
    boxWidth  = 0.6;
    bWidth    = 0.3;
    bStart    = 0.35;
    textStart = (1-textWidth-boxWidth - xSpace)/2 -xSpace;
    boxStart  = textStart +textWidth +xSpace;
    
    uicontrol(gui.sourceWindow,nb_constant.LABEL,...
        'string',               'Source:',...
        'position',             [textStart yStart textWidth Height]);
    gui.sourceSelect = uicontrol(gui.sourceWindow,nb_constant.POPUP,...
        'string',               {''},...
        'position',             [boxStart yStart boxWidth Height],...       
        'callback',             @gui.sourceCallback);
    
    uicontrol(gui.sourceWindow,nb_constant.BUTTON,...
        'position',     [bStart - bWidth, yStart - Height - 0.025, bWidth, Height],...
        'string',       'Source List',...
        'callback',     @gui.sourceListCallback,...
        'enable',       enable);
    
    uicontrol(gui.sourceWindow,nb_constant.BUTTON,...
        'position',     [bStart, yStart - Height - 0.025, bWidth, Height],...
        'string',       'Break link',...
        'callback',     @gui.breakLinkCallback,...
        'enable',       enable);
    
    uicontrol(gui.sourceWindow,nb_constant.BUTTON,...
        'position',     [bStart + bWidth, yStart - Height - 0.025, bWidth, Height],...
        'string',       'Delete',...
        'callback',     @gui.deleteCallback,...
        'enable',       enable);
        
    % Create panels
    %--------------------------------------------------------------
    % Positions
    spaceX          = 0.05;
    spaceY          = 0.04;
    panelWidth      = 0.9;
    panelHeight     = 0.75;
    textStart       = spaceX;
    textWidth       = 0.2;
    boxStart        = textStart + textWidth + spaceX;
    boxWidth        = 0.6;
    Height          = 0.065;
    listHeight      = 0.22;
    yLevel1         = 1 - Height - spaceY;
    yLevel2         = yLevel1 - listHeight - spaceY;
    yLevel3         = yLevel2 - Height - spaceY;
    yLevel4         = yLevel3 - Height - spaceY;
    yLevel5         = yLevel4 - Height - spaceY;
    yLevel6         = yLevel5 - Height - spaceY;
    yLevel7         = yLevel6 - Height - spaceY;
    yLevel8         = yLevel7 - Height - spaceY;
    
    gui.famePanel = uipanel(gui.sourceWindow,...
        'units',            'normal',...
        'position',         [spaceX spaceY panelWidth panelHeight],...
        'visible',          'off');
    
    gui.nb_tsPanel = uipanel(gui.sourceWindow,...
        'units',            'normal',...
        'position',         [spaceX spaceY panelWidth panelHeight],...
        'visible',          'off'); 
    
    gui.nb_csPanel = uipanel(gui.sourceWindow,...
        'units',            'normal',...
        'position',         [spaceX spaceY panelWidth panelHeight],...
        'visible',          'off');
    
    gui.nb_dataPanel = uipanel(gui.sourceWindow,...
        'units',            'normal',...
        'position',         [spaceX spaceY panelWidth panelHeight],...
        'visible',          'off');
    
    gui.smartPanel = uipanel(gui.sourceWindow,...
        'units',            'normal',...
        'position',         [spaceX spaceY panelWidth panelHeight],...
        'visible',          'off');
    
    % Populate fame panel
    uicontrol(gui.famePanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel1 textWidth Height],...
        'string',       'Source');    
    gui.fameSource = uicontrol(gui.famePanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel1 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'on',...
        'callback',     @gui.changeSourceCallback);
    uicontrol(gui.famePanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel2+(listHeight-Height) textWidth Height],...
        'string',       'Variables');
    gui.fameVar = uicontrol(gui.famePanel,...
        'style',        'listbox',...
        'units',        'normal',...
        'position',     [boxStart yLevel2 boxWidth listHeight],...
        'background',   [1 1 1],....
        'string',       {''});
    uicontrol(gui.famePanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel3 textWidth Height],...
        'string',       'Start Date');    
    gui.fameStDate = uicontrol(gui.famePanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel3 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'off');
    uicontrol(gui.famePanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel4 textWidth Height],...
        'string',       'End Date');    
    gui.fameEndDate =uicontrol(gui.famePanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel4 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'off');
    uicontrol(gui.famePanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel5 textWidth Height],...
        'string',       'Frequency');    
    gui.fameFreq = uicontrol(gui.famePanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel5 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'off');
    uicontrol(gui.famePanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel6 textWidth Height],...
        'string',       'Vintage');    
    gui.fameVintage = uicontrol(gui.famePanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel6 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'on',...
        'callback',     @gui.vintageCallback);
    uicontrol(gui.famePanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel7 textWidth Height],...
        'string',       'Host');    
    gui.fameHost = uicontrol(gui.famePanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel7 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'off');
    uicontrol(gui.famePanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel8 textWidth Height],...
        'string',       'Port');    
    gui.famePort = uicontrol(gui.famePanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel8 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'off');
    
    % Populate nb_ts panel
    uicontrol(gui.nb_tsPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel1 textWidth Height],...
        'string',       'Source');    
    gui.tsSource = uicontrol(gui.nb_tsPanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel1 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'on',...
        'callback',     @gui.changeSourceCallback);
    uicontrol(gui.nb_tsPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel2+(listHeight-Height) textWidth Height],...
        'string',       'Variables');
    gui.tsVar = uicontrol(gui.nb_tsPanel,...
        'style',        'listbox',...
        'units',        'normal',...
        'position',     [boxStart yLevel2 boxWidth listHeight],...
        'background',   [1 1 1],....
        'string',       {''});
    uicontrol(gui.nb_tsPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel3 textWidth Height],...
        'string',       'Start Date');    
    gui.tsStDate = uicontrol(gui.nb_tsPanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel3 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'off');
    uicontrol(gui.nb_tsPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel4 textWidth Height],...
        'string',       'End Date');    
    gui.tsEndDate = uicontrol(gui.nb_tsPanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel4 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'off');
    gui.tsSheetText = uicontrol(gui.nb_tsPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel5 textWidth Height],...
        'string',       'Sheet');    
    gui.tsSheet = uicontrol(gui.nb_tsPanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel5 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'on',...
        'callback',     @gui.sheetCallback);
    gui.tsRangeText = uicontrol(gui.nb_tsPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel6 textWidth Height],...
        'string',       'Range');    
    gui.tsRange = uicontrol(gui.nb_tsPanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel6 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'off');
    gui.tsTransposeText = uicontrol(gui.nb_tsPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel7 textWidth Height],...
        'string',       'Transposed');    
    gui.tsTranspose = uicontrol(gui.nb_tsPanel,...
        'style',        'radiobutton',...
        'units',        'normal',...
        'position',     [boxStart yLevel7 boxWidth Height],...
        'enable',       'off');
    
    % Populate nb_cs Panel
    uicontrol(gui.nb_csPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel1 textWidth Height],...
        'string',       'Source');    
    gui.csSource = uicontrol(gui.nb_csPanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel1 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'on',...
        'callback',     @gui.changeSourceCallback);
    uicontrol(gui.nb_csPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel2+(listHeight-Height) textWidth Height],...
        'string',       'Variables');
    gui.csVar = uicontrol(gui.nb_csPanel,...
        'style',        'listbox',...
        'units',        'normal',...
        'position',     [boxStart yLevel2 boxWidth listHeight],...
        'background',   [1 1 1],....
        'string',       {''});
    uicontrol(gui.nb_csPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel5+(listHeight-Height) textWidth Height],...
        'string',       'Types');
    gui.csType = uicontrol(gui.nb_csPanel,...
        'style',        'listbox',...
        'units',        'normal',...
        'position',     [boxStart yLevel5 boxWidth listHeight],...
        'background',   [1 1 1],....
        'string',       {''});  
    gui.csSheetText = uicontrol(gui.nb_csPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel6 textWidth Height],...
        'string',       'Sheet');
    gui.csSheet = uicontrol(gui.nb_csPanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel6 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'on',...
        'callback',     @gui.sheetCallback);
    gui.csRangeText = uicontrol(gui.nb_csPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel7 textWidth Height],...
        'string',       'Range');
    gui.csRange = uicontrol(gui.nb_csPanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel7 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'off');
    gui.csTransposeText = uicontrol(gui.nb_csPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel8 textWidth Height],...
        'string',       'Transposed');
    gui.csTranspose = uicontrol(gui.nb_csPanel,...
        'style',        'radiobutton',...
        'units',        'normal',...
        'position',     [boxStart yLevel8 boxWidth Height],...
        'enable',       'off');
    
    % Populate nb_data panel
    uicontrol(gui.nb_dataPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel1 textWidth Height],...
        'string',       'Source');    
    gui.dataSource = uicontrol(gui.nb_dataPanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel1 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'on',...
        'callback',     @gui.changeSourceCallback);
    uicontrol(gui.nb_dataPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel2+(listHeight-Height) textWidth Height],...
        'string',       'Variables');
    gui.dataVar = uicontrol(gui.nb_dataPanel,...
        'style',        'listbox',...
        'units',        'normal',...
        'position',     [boxStart yLevel2 boxWidth listHeight],...
        'background',   [1 1 1],....
        'string',       {''});
    uicontrol(gui.nb_dataPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel3 textWidth Height],...
        'string',       'Start Obs');    
    gui.dataStDate = uicontrol(gui.nb_dataPanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel3 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'off');
    uicontrol(gui.nb_dataPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel4 textWidth Height],...
        'string',       'End Obs');    
    gui.dataEndDate = uicontrol(gui.nb_dataPanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel4 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'off');
    gui.dataSheetText = uicontrol(gui.nb_dataPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel5 textWidth Height],...
        'string',       'Sheet');    
    gui.dataSheet = uicontrol(gui.nb_dataPanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel5 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'on',...
        'callback',     @gui.sheetCallback);
    gui.dataRangeText = uicontrol(gui.nb_dataPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel6 textWidth Height],...
        'string',       'Range');    
    gui.dataRange = uicontrol(gui.nb_dataPanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevel6 boxWidth Height],...
        'background',   [1 1 1],....
        'enable',       'off');
    gui.dataTransposeText = uicontrol(gui.nb_dataPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevel7 textWidth Height],...
        'string',       'Transposed');    
    gui.dataTranspose = uicontrol(gui.nb_dataPanel,...
        'style',        'radiobutton',...
        'units',        'normal',...
        'position',     [boxStart yLevel7 boxWidth Height],...
        'enable',       'off');
    
    % Populate SMART panel
    smartListHeight = 0.6;
    yLevelVar       = 1 - smartListHeight - spaceY; 
    uicontrol(gui.smartPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevelVar+(smartListHeight-Height) textWidth Height],...
        'string',       'Variables');
    gui.smartVar = uicontrol(gui.smartPanel,...
        'style',        'listbox',...
        'units',        'normal',...
        'position',     [boxStart yLevelVar boxWidth smartListHeight],...
        'background',   [1 1 1],....
        'string',       {''});
    yLevelVint = yLevelVar - Height - spaceY; 
    uicontrol(gui.smartPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevelVint textWidth Height],...
        'string',       'Context');    
    gui.smartVint = uicontrol(gui.smartPanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevelVint boxWidth Height],...
        'background',   [1 1 1],....
        'string',       '',...
        'enable',       'on',...
        'callback',     @gui.vintageCallback);
    yLevelFreq = yLevelVint - Height - spaceY; 
    uicontrol(gui.smartPanel,...
        'style',        'text',...
        'units',        'normal',...
        'position',     [textStart yLevelFreq textWidth Height],...
        'string',       'Frequency');    
    gui.smartFreq = uicontrol(gui.smartPanel,...
        'style',        'edit',...
        'units',        'normal',...
        'position',     [boxStart yLevelFreq boxWidth Height],...
        'background',   [1 1 1],....
        'string',       '',....
        'enable',       'off');
    
    gui.updateGUI();
    
    % Make the GUI visible.
    %--------------------------------------------------------------
    set(gui.sourceWindow,'Visible','on');
    
end


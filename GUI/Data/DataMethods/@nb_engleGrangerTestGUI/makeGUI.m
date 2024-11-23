function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG. Makes the window for Engle-Granger test.
% 
% Written by Eyo Herstad

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Check if there are enough variables
    if gui.data.numberOfVariables < 2
        nb_errorWindow('Cannot do cointegration test without at least two variables.');
        return
    end

    % Create Window
    %--------------------------------------------------------------
    gui.egTestWindow = nb_guiFigure(gui.parent,'Engle-Granger Test',[50 40 80 30],'modal','off');
    
    % Create first layer of panels
    %-------------------------------
    optionsPanel = uipanel(gui.egTestWindow,...
        'title',        '',...
        'units',        'normal',...
        'borderType',   'none',...
        'position',     [0 0 1 1]);
    
    varSelPanel = uipanel(gui.egTestWindow,...
        'title',        '',...
        'units',        'normal',...
        'visible',      'off',...
        'borderType',   'none',...
        'position',     [0 0 1 1]);
    
    % Var selection panel
    %--------------------------------------------------------------
    varSelListBox = uicontrol(varSelPanel,...
        'style',        'listbox',...
        'string',       gui.data.variables,...
        'value',        1:gui.data.numberOfVariables,...
        'max',          2,...
        'background',   [1 1 1],...
        'callback',     @gui.varSelCallback,...
        'units',        'normal',...
        'position',     [0.05, 0.15, 0.9, 0.8]);
    uicontrol(varSelPanel,...
        'style',        'pushbutton',...
        'string',       'Back',...
        'units',        'normal',...
        'callback',     @gui.switchBackCallback,...
        'position',     [0.4 0.05 0.2 0.05]);
    
    % Create option panels
    %--------------------------------------------------------------
    % Positions
    xSpace = 0.05;
    ySpace = 0.04;
    testPanelHeight = 0.15;
    testPanelWidth  = 0.7;
    panelStart = 0.12;
    testPanelStart = 1 - ySpace - testPanelHeight;
    panelWidth = (1 - ySpace*3)/2;
    rightPanelHeightTot = 1 - panelStart - ySpace*2 -testPanelHeight;
    leftPanelHeight = rightPanelHeightTot/2 - 0.0125;
    rightPanelxStart = 1-xSpace - panelWidth;
    leftPanelStart2 = panelStart + leftPanelHeight + 0.025;
    buttonWidth = 0.2;
    buttonHeight = 0.05;
    buttonStart1 = 1 - xSpace - buttonWidth;
    buttonStart2 = buttonStart1 - xSpace - buttonWidth;
    
    testTypePanel = uipanel(optionsPanel,...
        'title',        'Test',...
        'units',        'normal',...
        'position',     [xSpace testPanelStart testPanelWidth testPanelHeight]);
    
    levelDiffPanel = uibuttongroup(optionsPanel,...
        'title',                'Transformation',...
        'units',                'normal',...
        'SelectionChangeFcn',   '',...
        'position',             [xSpace panelStart panelWidth leftPanelHeight]);
    
    interceptPanel = uibuttongroup(optionsPanel,...
        'title',                'Equation assumption',...
        'units',                'normal',...
        'SelectionChangeFcn',   '',...
        'position',             [xSpace leftPanelStart2 panelWidth leftPanelHeight]);
    
    lagLengthPanel = uibuttongroup(optionsPanel,...
        'units',                'normal',...
        'title',                'Lag length',...
        'SelectionChangeFcn',   @gui.lagLengthCallback,...
        'position',             [rightPanelxStart, leftPanelStart2, panelWidth, leftPanelHeight]);
    
    spectralPanel = uipanel(optionsPanel,...
        'title',                'Spectral estimation method',...
        'units',                'normal',...
        'position',             [rightPanelxStart panelStart panelWidth leftPanelHeight],...
        'visible',              'off');
    
    bandwidthPanel = uibuttongroup(optionsPanel,...
        'title',                'Bandwidth',...
        'units',                'normal',...
        'SelectionChangeFcn',   @gui.bandwidthCallback,...
        'position',             [rightPanelxStart panelStart panelWidth leftPanelHeight],...
        'visible',              'off');
    
    addOptionsPanel = uipanel(optionsPanel,...
        'title',                'Other options',...
        'units',                'normal',...
        'position',             [rightPanelxStart panelStart panelWidth leftPanelHeight],...
        'visible',              'on');
    
    % Create buttons
    uicontrol(optionsPanel,...
        'style',        'pushbutton',...
        'units',        'normal',...
        'position',     [buttonStart2/2 - buttonWidth, ySpace, buttonWidth*2, buttonHeight],...
        'string',       'Select Variables',...
        'callback',     @gui.switchToVarSelCallback);
    
    uicontrol(optionsPanel,...
        'style',        'pushbutton',...
        'units',        'normal',...
        'position',     [buttonStart1 ySpace buttonWidth buttonHeight],...
        'string',       'Cancel',...
        'callback',      @gui.exit);
    
    uicontrol(optionsPanel,...
        'style',        'pushbutton',...
        'units',        'normal',...
        'position',     [buttonStart2 ySpace buttonWidth buttonHeight],...
        'string',       'OK',...
        'callback',      @gui.okCallback);
    
    % Populate panels/buttongroups
    %-------------------------------------------------------------
    
    % Type panel
    typeList = {'Augmented Dickey-Fuller'};
    gui.testTypeBox = uicontrol(testTypePanel,...
        'style',        'popupmenu',...
        'background',   [1 1 1],...
        'units',        'normal',...
        'string',       typeList,...
        'position',     [xSpace 0.3 0.9 0.5],...
        'callback',     @gui.switchPanel);
    
    % Level buttongroup
    rButtonHeight = 0.25;
    rButtonWidth  = 0.8;
    spaceY = 0.08;
    rButtonLevel1 = spaceY + rButtonHeight + spaceY;
    rButtonLevel2 = rButtonLevel1 + rButtonHeight + spaceY;
    boxWidth = 1 - rButtonWidth;
    boxHeight = 0.1;
    boxStart = 0.7;
    
    levelBtn = uicontrol(levelDiffPanel,...
        'style',        'radiobutton',...
        'string',       'Level',...
        'units',        'normal',...
        'position',     [xSpace rButtonLevel2 rButtonWidth rButtonHeight]);
   diff1Btn = uicontrol(levelDiffPanel,...
        'style',        'radiobutton',...
        'string',       '1st difference',...
        'units',        'normal',...
        'position',     [xSpace rButtonLevel1 rButtonWidth rButtonHeight]);
   diff2Btn = uicontrol(levelDiffPanel,...
        'style',        'radiobutton',...
        'string',       '2nd difference',...
        'units',        'normal',...
        'position',     [xSpace spaceY rButtonWidth rButtonHeight]);
    
    % Intercept panel
    spaceY = 0.04;
    rButtonHeight = 0.2;
    rButtonLevel1 = spaceY + rButtonHeight + spaceY;
    rButtonLevel2 = rButtonLevel1 + rButtonHeight + spaceY;
    rButtonLevel3 = rButtonLevel2 + rButtonHeight + spaceY;
    
    interceptBtn = uicontrol(interceptPanel,...
        'style',        'radiobutton',...
        'string',       'Intercept',...
        'units',        'normal',...
        'position',     [xSpace rButtonLevel3 rButtonWidth rButtonHeight]);
   trendInterceptBtn = uicontrol(interceptPanel,...
        'style',        'radiobutton',...
        'string',       'Trend',...
        'units',        'normal',...
        'position',     [xSpace rButtonLevel2 rButtonWidth rButtonHeight]);
   quadTrendBtn = uicontrol(interceptPanel,...
        'style',        'radiobutton',...
        'string',       'Squared and linear trend',...
        'units',        'normal',...
        'position',     [xSpace rButtonLevel1 rButtonWidth rButtonHeight]);   
   noTrendInterceptBtn = uicontrol(interceptPanel,...
        'style',        'radiobutton',...
        'string',       'None',...
        'units',        'normal',...
        'position',     [xSpace spaceY rButtonWidth rButtonHeight]);
    
    % Lag panel
    rButtonHeight = 0.2;
    ySpaceLag     = 0.06;
    lagBtnHeight = rButtonHeight*3/4;
    laxBoxheight = boxHeight+0.02;
    yLevel1 = 1-lagBtnHeight-0.02;
    yLevel2 = yLevel1 - lagBtnHeight - ySpaceLag;
    yLevel3 = yLevel2 - lagBtnHeight - ySpaceLag;
    bLevel1 = 1-rButtonHeight/2*3/2-0.02;
    bLevel2 = bLevel1-rButtonHeight/2*3/2-0.02;
    
    
    criteriaList = {'Akaike information criterion';...
        'Modified Akaike information criterion';...
        'Schwarz information criterion';...
        'Modified Schwarz information criterion';...
        'Hannan-Quinn information criterion';...
        'Modified Hannan-Quinn information criterion'...
        };
    
    autSelectBtn = uicontrol(lagLengthPanel,...
        'style',                'radiobutton',...
        'string',               'Automatic selection',...
        'units',                'normal',...
        'position',             [xSpace yLevel1 rButtonWidth lagBtnHeight]);
    criterionBox = uicontrol(lagLengthPanel,...
        'style',                'popupmenu',...
        'background',           [1 1 1],...
        'string',               criteriaList,...
        'units',                'normal',...
        'position',             [xSpace yLevel2 rButtonWidth lagBtnHeight]);
    maxText = uicontrol(lagLengthPanel,...
        'style',                'text',...
        'string',               'Maximum: ',...
        'horizontalAlignment',  'left',...
        'units',                'normal',...
        'position',             [xSpace+0.1 yLevel3 rButtonWidth laxBoxheight]);
    maxLagLengthBox = uicontrol(lagLengthPanel,...
        'style',                'edit',...
        'string',               '11',...
        'units',                'normal',...
        'background',           [1 1 1],...
        'position',             [boxStart yLevel3+0.01 boxWidth laxBoxheight]);
    userSelectBtn = uicontrol(lagLengthPanel,...
        'style',                'radiobutton',...
        'string',               'User specified: ',...
        'units',                'normal',...
        'position',             [xSpace spaceY rButtonWidth lagBtnHeight]);
    userLagSelect = uicontrol(lagLengthPanel,...
        'style',                'edit',...
        'string',               '2',...
        'units',                'normal',...
        'enable',               'off',...
        'background',           [1 1 1],...
        'position',             [boxStart spaceY+0.01 boxWidth laxBoxheight]);
    
    % Additional options panel
    seasonal = {'No seasonal dummies','Centered seasonal dummies','Uncentered seasonal dummies'};
    height = 0.2;
    space = 0.04;
    
    dependentvars = gui.data.variables;
    uicontrol(addOptionsPanel,...
        'style',                'text',...
        'string',               'Dependent Var:',...
        'horizontalAlignment',  'left',...
        'units',                'normal',...
        'position',             [0.05, 1-height-space, 0.5, height-0.05]);
    dependentBox = uicontrol(addOptionsPanel,...
        'style',                'popupmenu',...
        'string',               dependentvars,...
        'units',                'normal',...
        'background',           [1 1 1],...
        'position',             [0.52 1-height-space 0.43 height]);
    
    datesList = dates(gui.data);
    uicontrol(addOptionsPanel,...
        'style',                'text',...
        'string',               'Start',...
        'horizontalAlignment',  'left',...
        'units',                'normal',...
        'position',             [0.05, 1-height*2-space*2, 0.3, height-0.05]);
    startDate = uicontrol(addOptionsPanel,...
        'style',                'popupmenu',...
        'string',               datesList,...
        'max',                  1,...
        'units',                'normal',...
        'background',           [1 1 1],...
        'position',             [0.32, 1-height*2-space*2, 0.63, height]);
    
    uicontrol(addOptionsPanel,...
        'style',                'text',...
        'string',               'End',...
        'horizontalAlignment',  'left',...
        'units',                'normal',...
        'position',             [0.05, 1-height*3-space*3, 0.3, height-0.05]);
    endDate = uicontrol(addOptionsPanel,...
        'style',                'popupmenu',...
        'string',               flipud(datesList),...
        'max',                  1,...
        'units',                'normal',...
        'background',           [1 1 1],...
        'position',             [0.32, 1-height*3-space*3, 0.63, height]);
     
    seasonalBox = uicontrol(addOptionsPanel,...
        'style',                'popupmenu',...
        'string',               seasonal,...
        'enable',               'off',...
        'units',                'normal',...
        'background',           [1 1 1],...
        'position',             [0.05, 1-height*4-space*4, 0.9, height]);
    
    % Spectral panel
    spectralList = {'Bartlett kernel','Parzen kernel','Quadratic spectral kernel'};
    kernelBox = uicontrol(spectralPanel,...
        'style',        'popupmenu',...
        'units',        'normal',...
        'string',       spectralList,...
        'background',   [1 1 1],...
        'position',     [0.05 0.1 0.9 0.7]);
    
    % Bandwidth panel
    methodList = {'Newey-West Bandwidth';'Andrews Bandwidth'};
    
    autSelectBtn2 = uicontrol(bandwidthPanel,...
        'style',        'radiobutton',...
        'string',       'Automatic Selection:',...
        'units',        'normal',...
        'position',     [xSpace bLevel1 rButtonWidth rButtonHeight/2*3/2]);
    methodSelectBox = uicontrol(bandwidthPanel,...
        'style',        'popupmenu',...
        'background',	[1 1 1],...
        'string',       methodList,...
        'units',        'normal',...
        'position',     [xSpace bLevel2 rButtonWidth rButtonHeight/2*3/2]);
    
    userSelectBtn2 = uicontrol(bandwidthPanel,...
        'style',        'radiobutton',...
        'string',       'User specified: ',...
        'units',        'normal',...
        'position',     [xSpace spaceY*3/2 rButtonWidth rButtonHeight/2*3/2]);
    
    bandwidthSelectBox = uicontrol(bandwidthPanel,...
        'style',        'edit',...
        'string',       '3',...
        'units',        'normal',...
        'enable',       'off',...
        'background',	[1 1 1],...
        'position',     [boxStart spaceY*3/2 boxWidth boxHeight*3/2]);
        
    % Assign panels to structure
    %----------------------------------------------------------------
    gui.unitRootPanels.optionsPanel     = optionsPanel;
    gui.unitRootPanels.varSelPanel      = varSelPanel;
    gui.unitRootPanels.levelDiffPanel   = levelDiffPanel;
    gui.unitRootPanels.interceptPanel   = interceptPanel;
    gui.unitRootPanels.lagLengthPanel   = lagLengthPanel;
    gui.unitRootPanels.spectralPanel    = spectralPanel;
    gui.unitRootPanels.bandwidthPanel   = bandwidthPanel;
    
    % Assign components to structures
    %---------------------------------------------------------------
    gui.varSelPanelComponents.varSelListBox = varSelListBox;
    
    gui.levelPanelComponents.levelBtn       = levelBtn;
    gui.levelPanelComponents.diff1Btn       = diff1Btn;
    gui.levelPanelComponents.diff2Btn       = diff2Btn;
    
    gui.interceptPanelComponents.interceptBtn        = interceptBtn;
    gui.interceptPanelComponents.trendInterceptBtn   = trendInterceptBtn;
    gui.interceptPanelComponents.noTrendInterceptBtn = noTrendInterceptBtn;
    gui.interceptPanelComponents.quadTrendBtn        = quadTrendBtn;
    
    gui.optionPanelComponents.dependentBox  = dependentBox;
    gui.optionPanelComponents.seasonalBox   = seasonalBox;
    gui.optionPanelComponents.startDate     = startDate;
    gui.optionPanelComponents.endDate       = endDate;
    
    gui.lagPanelComponents.autSelectBtn     = autSelectBtn;
    gui.lagPanelComponents.criterionBox     = criterionBox;
    gui.lagPanelComponents.maxText          = maxText; 
    gui.lagPanelComponents.maxLagLengthBox  = maxLagLengthBox;
    gui.lagPanelComponents.userSelectBtn    = userSelectBtn;
    gui.lagPanelComponents.userLagSelect    = userLagSelect;
    
    gui.bandwidthComponents.autSelectBtn        = autSelectBtn2; 
    gui.bandwidthComponents.methodSelectBox     = methodSelectBox;
    gui.bandwidthComponents.userSelectBtn       = userSelectBtn2;
    gui.bandwidthComponents.bandwidthSelectBox  = bandwidthSelectBox;
    gui.bandwidthComponents.kernelBox           = kernelBox;
    
    % Make the GUI visible.
    %--------------------------------------------------------------
    set(gui.egTestWindow,'Visible','on');
    
end


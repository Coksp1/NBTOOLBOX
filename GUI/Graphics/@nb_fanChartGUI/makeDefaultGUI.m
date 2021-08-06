function makeDefaultGUI(gui)
% Syntax:
%
% makeDefaultGUI(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
        
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Test if the data of the graph contains any of the variables
    % which can be added default fans
    %--------------------------------------------------------------
    plotterT = gui.plotter;
    
    if plotterT.DB.frequency ~= 4
        nb_errorWindow('It is not possible to add default fan chart when frequency of the data is not quarterly');
        return
    end
    
    variables   = plotterT.variablesToPlot;
    defaultVars = {'QSA_GAPNB_Y','QSA_GAP_Y','QUA_DPY_PCPI','QUA_DPY_PCPIJAE',...
                   'QUA_DPY_PCPIXE','QUA_DPY_PCPIXE_R','QUA_RNFOLIO','QUA_RNFOLIO_LATESTMPR'};
    index       = ismember(variables,defaultVars);
    variables   = variables(index);
    
    if isempty(variables)
        nb_errorWindow(['Non of the variables you have plotted can be added a default fan chart. Only the variables '...
                        'QSA_GAPNB_Y, QSA_GAP_Y, QUA_DPY_PCPI, QUA_DPY_PCPIJAE, QUA_DPY_PCPIXE, QUA_DPY_PCPIXE_R, '...
                        'QUA_RNFOLIO and QUA_RNFOLIO_LATESTMPR can be added a default fan chart.'])
        return
    end

    % Create the main window
    %--------------------------------------------------------------
    gui.figureHandle = nb_guiFigure(gui.plotter.parent,'Fan Chart Properties',[40   15  85.5   31.5],'modal','off');              
    
    % Coordinates
    startPopX = 0.3;
    widthPop  = 0.35;
    heightPop = 0.055;
    startTX   = 0.04;
    widthT    = widthPop - startTX*2;
    heightT   = 0.053;
    kk        = 9;
    spaceYPop = (1 - heightPop*kk)/(kk +1);
    extra     = -(heightPop - heightT)*5;
    buttonkk  = 2;
    
    % Select default fans start date
    %--------------------------------------------------------------
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 gui.figureHandle,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Forecast Start Date');

    plotterT.setSpecial('returnLocal',1);
    dFans = plotterT.defaultFans;
    plotterT.setSpecial('returnLocal',0);      
          
    if isa(dFans,'nb_date') 
        if isempty(dFans)
            dFans = '';
        else
            dFans = dFans.toString();
        end
    end
          
    ed1 = uicontrol(...
              'units',                  'normalized',...
              'position',               [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',                 gui.figureHandle,...
              'background',             [1 1 1],...
              'style',                  'edit',...
              'horizontalAlignment',    'left',...
              'Interruptible',          'off',...
              'string',                 dFans);
          
    % Select default fan chart variable
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 gui.figureHandle,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Select Variable');

    fanVar = plotterT.fanVariable;
    value  = find(strcmp(fanVar,variables),1);
    if isempty(value)
        value = 1;
    end
          
    ed2 = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',         gui.figureHandle,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'string',         variables,...
              'value',          value);   
          
    % Select file
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 gui.figureHandle,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Select File');

    files   = {'','current','MPR152','MPR173'};
    fanFile = plotterT.fanFile;
    value   = find(strcmp(fanFile,files),1);
    if isempty(value)
        value = 1;
    end
          
    ed3 = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',         gui.figureHandle,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'string',         files,...
              'value',          value);   
                
    % Fan chart type
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 gui.figureHandle,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Type');

    types = {'percentiles','shaded'};
    fanM  = plotterT.fanMethod;
    value = find(strcmp(fanM,types),1);
    if isempty(value)
        value = 1;
    end
          
    ed4 = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',         gui.figureHandle,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'string',         types,...
              'value',          value);         
          
    % Finish button      
    %-------------------------------------------------------------- 
    buttonHeight = 0.05;
    buttonWidth  = 0.2;
    buttonXLoc   = 0.75 - buttonWidth/2;
    buttonYLoc   = (heightPop*(buttonkk-1) + spaceYPop*buttonkk)/2 - buttonHeight/2;
    
    uicontrol(...
              'units',              'normalized',...
              'position',           [buttonXLoc, buttonYLoc, buttonWidth, buttonHeight],...
              'parent',             gui.figureHandle,...
              'style',              'pushbutton',...
              'Interruptible',      'off',...
              'horizontalAlignment','left',...
              'string',             'Finish',...
              'callback',           {@finishUp,gui,ed1,ed2,ed3,ed4});      
    
    % Set the window visible   
    %--------------------------------------------------------------
    set(gui.figureHandle,'visible','on');

end

%==================================================================
% Callbacks
%==================================================================
function finishUp(~,~,gui,ed1,ed2,ed3,ed4)

    plotterT = gui.plotter;

    % Get default date
    string = get(ed1,'string');
    if isempty(string)
        nb_errorWindow('You must provide a forecast start date.');
        return
    end
    
    [newValue,message,obj] = nb_interpretDateObsTypeInputGUI(plotterT,string);
    
    if ~isempty(message)
        nb_errorWindow(message);
        return
    end
    
    if obj > plotterT.DB.endDate
        nb_errorWindow(['The forecast start date ''' obj.toString() ''' is after the end date of the data (' plotterT.DB.endDate.toString() '), which is not possible.']);
        return
    elseif obj > plotterT.endGraph
        nb_errorWindow(['The forecast start date ''' obj.toString() ''' is after the end date of the graph (' plotterT.endGraph.toString() '), which is not possible.']);
        return
    elseif obj < plotterT.startGraph
        nb_errorWindow(['The forecast start date ''' obj.toString() ''' is before the start date of the graph (' plotterT.startGraph.toString() '), which is not possible.']);
        return
    end
    
    % Update graph object
    plotterT.defaultFans    = newValue;
    plotterT.fanFile        = nb_getUIControlValue(ed3);
    plotterT.fanMethod      = nb_getUIControlValue(ed4);
    plotterT.fanVariable    = nb_getUIControlValue(ed2);
    plotterT.fanVariables   = {};
    plotterT.fanDatasets    = {};
    plotterT.fanPercentiles = [.3,.5,.7,.9];
    plotterT.fanColor       = 'nb';
    if strcmpi(plotterT.fanMethod,'shaded')
        plotterT.fanLegend = false;
    end
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');
    
end

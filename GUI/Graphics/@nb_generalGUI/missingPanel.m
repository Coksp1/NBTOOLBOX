function missingPanel(gui)
% Syntax:
%
% missingPanel(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get graph object 
    plotterT = gui.plotter;

    % Create panel
    %--------------------------------------------------------------
    uip = uipanel('parent',              gui.figureHandle,...
                  'title',               '',...
                  'visible',             'off',...
                  'borderType',          'none',... 
                  'units',               'normalized',...
                  'position',            [0.22, 0.02, 1 - 0.24, 0.96]); 
    gui.panelHandle4 = uip;
    
    startPopX = 0.3;
    widthPop  = 0.35;
    heightPop = 0.055;
    startTX   = 0.04;
    widthT    = widthPop - startTX*2;
    heightT   = 0.053;
%     widthB    = 1 - startPopX - widthPop - startTX*2;
%     startB    = startPopX + widthPop + startTX;
    spaceYPop = (1 - heightPop*9)/10;
    extra     = -(heightPop - heightT)*5;
    kk        = 9;
    
    if isa(plotterT,'nb_graph_ts') || isa(plotterT,'nb_graph_data')
    
        % Missing Values interpretation
        %--------------------------------------------------------------
        uicontrol(...
                  'units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Missing Values');

        if isa(plotterT,'nb_graph_ts')
            options = {'none','interpolate','strip','both'};
        else
            options = {'none','interpolate'};
        end
        value   = find(strcmpi(plotterT.missingValues,options),1);

        uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         uip,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         options,...
                  'value',          value,....
                  'callback',       {@gui.set,'missingValues'});
              
    end
    
    if isa(plotterT,'nb_graph_ts')

        % Stop strip
        %--------------------------------------------------------------
        kk = kk - 1;
        uicontrol(...
                  'units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Stop Strip');


        if value == 3 || value == 4
            enable = 'on';
        else
            enable = 'off';
        end

        plotterT.setSpecial('returnLocal',1);
        date = plotterT.stopStrip;
        plotterT.setSpecial('returnLocal',0);   
        
        if isempty(date)
            date = '';
        else
            if isa(date,'nb_date')
                date = date.toString();
            end
        end
        
        h = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',          uip,...
                  'background',     [1 1 1],...
                  'style',          'edit',...
                  'Interruptible',  'off',...
                  'enable',         enable,...
                  'string',         date,...
                  'callback',       {@gui.set,'stopStrip'});

        gui.handle5 = h;
        
    end
    
end

function graphNor(obj,figureHandle,gui)
% Syntax:
% 
% graphNor(obj)
% 
% Description:
% 
% Plot the graph (norwegian )
% 
% Input:
% 
% - obj  : An object of class nb_graph_adv
%     
% Output:
% 
% The graph plotted on the screen (norwegian version)
%
% Examples:
%
% obj.graphNor()
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin<3
        gui = 0;
    end

    if nargin < 2
        figureHandle = nb_graphPanel('[4,3]',...
                         'advanced',       1,...
                         'visible',        'on',...
                         'units',          'characters',...
                         'position',       [40   15  220   50],...
                         'Color',          [1 1 1],...
                         'name',           '',...
                         'numberTitle',    'off',...
                         'dockControls',   'off',...
                         'menuBar',        'None',...
                         'toolBar',        'None');
        movegui(figureHandle.figureHandle,'center');
    end

    % Graph the figure
    %--------------------------------------------------------------
    languageTemp  = obj.plotter(1).language;
    fontUnitsTemp = obj.plotter(1).fontUnits;
    if isa(obj.plotter(1),'nb_graph')
        legAutoTemp = obj.plotter(1).legAuto;
    end
    pdfBookTemp = obj.plotter(1).pdfBook;
    flipTemp    = obj.plotter(1).flip;
    a4Temp      = obj.plotter(1).a4Portrait;
    
    for ii = 1:size(obj.plotter,2)
        obj.plotter(ii).language = 'norsk';
        obj.plotter(ii).set('fontUnits',obj.fontUnits);
    end
    if isempty(figureHandle)
        obj.plotter(1).setSpecial('advanced',1);
    else
        if ~isempty(figureHandle.children)
            % Delete the axes of the past created graph
            childs = figureHandle.children;
            for ii = 1:length(childs)
                childs(ii).deleteOption = 'all';
                delete(childs(ii))
            end
        end
        obj.plotter(1).setSpecial('figureHandle',figureHandle);
    end
    if size(obj.plotter,2) > 1
        obj.plotter(2).setSpecial('figureHandle',get(obj.plotter(1),'figureHandle'));
    end
    
    % Turn off the the legend information given through the 
    % 'fakeLegend' and 'patch' properties
    if isa(obj.plotter,'nb_graph')
        if gui
            obj.plotter(1).legAuto = 'on';
            if size(obj.plotter,2) > 1
                obj.plotter(2).legAuto = 'on';
            end
        else
            obj.plotter(1).legAuto = 'off';
            if size(obj.plotter,2) > 1
                obj.plotter(2).legAuto = 'off';
            end
        end
    end
    
    % Update the graph object
    for ii = 1:size(obj.plotter,2)
        obj.plotter(ii).pdfBook    = 1; 
        obj.plotter(ii).flip       = obj.flip;
        obj.plotter(ii).a4Portrait = obj.a4Portrait;
        obj.plotter(ii).saveName   = '';
        obj.plotter(ii).defaultFigureNumbering = obj.defaultFigureNumbering;
        graph(obj.plotter(ii));
    end

    % Save the graph to pdf
    %--------------------------------------------------------------
    saveFigure(obj);

    % Reset some properties
    %--------------------------------------------------------------
    for ii = 1:size(obj.plotter,2)
        if isempty(figureHandle)
            obj.plotter(ii).setSpecial('advanced',0);
        else
            obj.plotter(ii).setSpecial('figureHandle',[]);
        end
        obj.plotter(ii).a4Portrait = a4Temp;
        obj.plotter(ii).flip       = flipTemp;
        obj.plotter(ii).language   = languageTemp;
        if isa(obj.plotter,'nb_graph')
            obj.plotter(ii).legAuto                = legAutoTemp;
            obj.plotter(ii).defaultFigureNumbering = false;
        end
        obj.plotter(ii).pdfBook  = pdfBookTemp; 
        obj.plotter(ii).set('fontUnits',fontUnitsTemp);
    end
    
end

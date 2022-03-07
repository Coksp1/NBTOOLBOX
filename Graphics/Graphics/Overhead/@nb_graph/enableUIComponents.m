function enableUIComponents(obj,~,~)
% Syntax:
%
% enableUIComponents(obj,~,~)
%
% Description:
% 
% Enable UI components callback function. Used by DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotType = obj.plotType;

    % Enable/disable ui-components
    reorderM = findobj(obj.UIContextMenu,'tag','reorderMenu');
    if isa(obj,'nb_graph_ts')

        ch = findobj(obj.UIContextMenu,'tag','changeWhenDatesVsDates');
        if ~isempty(obj.datesToPlot)

            % When we switch to Dates vs Dates graph we need to prevent
            % the user of some options.
            set(ch,'Label','Select date')

            rh = findobj(obj.UIContextMenu,'tag','removeWhenRadarPie2');   
            set(rh,'enable','off');

            eh = findobj(obj.UIContextMenu,'tag','enableWhenLine');   
            set(eh,'enable','off');

            rh = findobj(obj.UIContextMenu,'tag','removedWhenDatesVsDates');
            set(rh,'enable','off');

            delete(get(reorderM,'children'));
            uimenu(reorderM,'Label','Dates','Callback',{@obj.reorderGUI,'dates'});
            uimenu(reorderM,'Label','Axes variables','Callback',{@obj.reorderGUI,'left'});
            return

        else
            set(ch,'Label','Select variable')

            rh = findobj(obj.UIContextMenu,'tag','removedWhenDatesVsDates');
            set(rh,'enable','on');

            delete(get(reorderM,'children'));
            uimenu(reorderM,'Label','Left axes variables','Callback',{@obj.reorderGUI,'left'});
            uimenu(reorderM,'Label','Right axes variables','Callback',{@obj.reorderGUI,'right'});

        end

    end

    if strcmpi(plotType,'pie') || strcmpi(plotType,'radar')
        enable = 'off';
    else
        enable = 'on';
    end
    rh = findobj(obj.UIContextMenu,'tag','removeWhenRadarPie');   
    set(rh,'enable',enable);
    rh = findobj(obj.UIContextMenu,'tag','removeWhenRadarPie2');   
    set(rh,'enable',enable);

    if strcmpi(plotType,'line')
        enable = 'on';
    else
        enable = 'off';
    end
    eh = findobj(obj.UIContextMenu,'tag','enableWhenLine');   
    set(eh,'enable',enable);

    if strcmpi(plotType,'scatter')
        enable = 'off';
    else
        enable = 'on';
    end  
    set(reorderM,'enable',enable);

end

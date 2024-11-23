function pasteAnnotationCallback(gui,hObject,~)
% Syntax:
%
% pasteAnnotationCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if strcmpi(gui.type,'advanced')
        if size(gui.plotterAdv.plotter,2) > 1
            index    = get(hObject,'userDate');
            plotterT = gui.plotterAdv.plotter(index);
        else
            plotterT = gui.plotter;
        end
    else
        plotterT = gui.plotter;
    end

    fig = get(plotterT,'figureHandle');
    ax  = get(plotterT,'axesHandle');
    ann = get(fig,'userdata');
    if isa(ann,'nb_annotation')
        ann = copy(ann);
        [~,cAxPoint] = nb_getCurrentPointInAxesUnits(fig,ax);
        if strcmpi(ann.units,'data')
            cAxPoint(1) = nb_pos2pos(cAxPoint(1),[0,1],ax.xLim,'normal',ax.xScale);
            cAxPoint(2) = nb_pos2pos(cAxPoint(2),[0,1],ax.yLim,'normal',ax.yScale);
        end
        if isprop(ann,'position')
            ann.position(1) = cAxPoint(1);
            ann.position(2) = cAxPoint(2);
        elseif isprop(ann,'xData') && isprop(ann,'yData')
            
            if length(ann.xData) > 1
                diffX     = diff(ann.xData);
                ann.xData = [cAxPoint(1),cAxPoint(1) + diffX];
            else
                ann.xData = cAxPoint(1);
            end
            if length(ann.yData) > 1
                diffY     = diff(ann.yData);
                ann.yData = [cAxPoint(2),cAxPoint(2) + diffY];
            else
                ann.yData = cAxPoint(2);
            end
            
        else
            nb_errorWindow(['Cannot paste an annotation object of class ' class(ann) '.'])
            return
        end
        old = plotterT.annotation;
        new = [old,{ann}];
        plotterT.annotation = new;
        plotterT.graph();
        notify(plotterT,'updatedGraph');
    else
        nb_errorWindow('There is no annotation object to paste.')
    end
    
end

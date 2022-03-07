function set(gui,hObject,~,type)
% Syntax:
%
% set(gui,hObject,event,type)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT  = gui.plotter;
    notifyInd = 1;
    
    switch lower(type)
        
        case 'axesscalelinewidth'
            
            plotterT.axesScaleLineWidth = get(hObject,'value');
        
        case 'language'
            
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            plotterT.language = selected;
        
        case 'shading'
            
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            plotterT.shading = selected;    
            
        case 'scale'
            
            string   = get(hObject,'string');
            value    = str2double(string);
            if isnan(value)
                nb_errorWindow(['The font scale must be set to a number greater then 0. Is ' string '.'])
                return
            elseif value <= 0
                nb_errorWindow(['The font scale must be set to a number greater then 0. Is ' string '.'])
                return
            end
            plotterT.scale = value;   
            
        case 'subplotsize1'
            
            string = get(hObject,'string');
            value  = round(str2double(string));
            if isnan(value)
                nb_errorWindow(['The subplot row size must be set to a number greater then 0. Is ' string '.'])
                return
            elseif value <= 0
                nb_errorWindow(['The subplot row size must be set to a number greater then 0. Is ' string '.'])
                return
            end
            subplotSize    = plotterT.subPlotSize;
            old            = subplotSize(1);
            subplotSize(1) = value;
            
            if isa(gui.plotter.parent,'nb_GUI')
                name = [gui.plotter.parent.guiName ': Set Subplot Size'];
            else
                name = 'Set Subplot Size';
            end
            
            if old > value
                
                notifyInd = 0;
                nb_confirmWindow('Are you sure you want to set the subplot row size. This will delete some graph objects?',...
                    @notSet,{@setSubplotSize,gui,subplotSize},name)
                
            else
                plotterT             = gui.plotter;
                plotterT.subPlotSize = subplotSize;
            end
            
        case 'subplotsize2'
            
            string = get(hObject,'string');
            value  = round(str2double(string));
            if isnan(value)
                nb_errorWindow(['The subplot column size must be set to a number greater then 0. Is ' string '.'])
                return
            elseif value <= 0
                nb_errorWindow(['The subplot column size must be set to a number greater then 0. Is ' string '.'])
                return
            end
            subplotSize    = plotterT.subPlotSize;
            old            = subplotSize(2);
            subplotSize(2) = value;
            
            if isa(gui.plotter.parent,'nb_GUI')
                name = [gui.plotter.parent.guiName ': Set Subplot Size'];
            else
                name = 'Set Subplot Size';
            end
            
            if old > value
                
                notifyInd = 0;
                nb_confirmWindow('Are you sure you want to set the subplot column size. This will delete some graph objects?',...
                    @notSet,{@setSubplotSize,gui,subplotSize},name)
                
            else
                plotterT             = gui.plotter;
                plotterT.subPlotSize = subplotSize;
            end
                
        case 'subplotspecial'
            
            plotterT.subPlotSpecial = get(hObject,'value');
            
        case 'manualaxesposition'
            
            plotterT.manualAxesPosition = get(hObject,'value');
            
    end
    
    % Notify listeners
    if notifyInd
        notify(gui,'changedGraph');
    end
     
end

%==================================================================
% Callback
%==================================================================
function notSet(hObject,~)

    close(get(hObject,'parent'));

end

function setSubplotSize(hObject,~,gui,subplotSize)

    close(get(hObject,'parent'));

    % Set the subplotsize property
    plotterT             = gui.plotter;
    plotterT.subPlotSize = subplotSize;
    
    % Delete the graphs not being displayed on the first page
    numberOfFitted = subplotSize(1)*subplotSize(2);
    graphs         = plotterT.graphObjects;
    oldGraphs      = {};
    if length(graphs) > numberOfFitted
        oldGraphs = graphs(numberOfFitted + 1:end);
        graphs    = graphs(1:numberOfFitted);
    end
    plotterT.graphObjects = graphs;
    
    % Delete the old axes (nb_axes objects)
    for ii = 1:length(oldGraphs)
       
        ax = get(oldGraphs{ii},'axesHandle');
        ax.deleteOption = 'all';
        delete(ax);
        
    end
    
    % Notify listeners
    notify(gui,'changedGraph');
    
end

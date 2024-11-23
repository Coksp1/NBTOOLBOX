function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
        
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Create window
    %--------------------------------------------------------------
    gui.figureHandle = nb_guiFigure(gui.plotter.parent,'Axes properties',[65,15,120,40],'modal','off');
    
    % Are we adding the color map panel?
    addColorMap = false;
    if isa(gui.plotter,'nb_graph_ts')
        if and(strcmpi(gui.plotter.plotType,'line'), strcmpi(gui.plotter.fanMethod,'graded'))
            addColorMap = true;
        end
    else
        if strcmpi(gui.plotter.plotType,'image')
            addColorMap = true;
        end
    end
    
    % Make button panel
    if any(strcmpi(gui.plotter.plotType,{'pie','donut'}))
        
        % Make button panel
        if strcmpi(gui.plotter.plotType,'donut')
            panels = {'Pie/Donut','X-Axis','General'};
        else
            panels = {'Pie/Donut','X-Axis','General'};
        end   
        gui.buttonPanel = nb_buttonPanel(gui.figureHandle,'type','uipanel',panels{:});
        
        % Fill in the panels
        piePanel(gui);
        if strcmpi(gui.plotter.plotType,'donut')
            xAxisPanel(gui);
        end
        generalPanel(gui);
        
    elseif strcmpi(gui.plotter.plotType,'radar')
        
        % Make button panel
        gui.buttonPanel = nb_buttonPanel(gui.figureHandle,'type','uipanel','Radar','General');       
        
        % Make panels
        radarPanel(gui);
        generalPanel(gui);
        
    else
        
        graphMethod = get(gui.plotter,'graphMethod');
        if ~strcmpi(graphMethod,'graph')
        
            % Make button panel
            gui.buttonPanel = nb_buttonPanel(gui.figureHandle,'type','uipanel','General');               

            % Make panels
            generalSubplotPanel(gui);
            
        else
            
            % Make button panel
            panels = {'X-Axis','X-Axis Labels'};
            if ~strcmpi(gui.plotter.plotType,'image')
                panels = [panels,{'Left Y-Axis','Right Y-Axis'}];
            end
            panels = [panels,{'General'}];
            if addColorMap
                panels = [panels,'Color Map'];
            end
            gui.buttonPanel = nb_buttonPanel(gui.figureHandle,'type','uipanel',panels{:});  
        
            % Make panels
            xAxisPanel(gui);
            xAxisLabelsPanel(gui);
            if ~strcmpi(gui.plotter.plotType,'image')
                yAxisPanel(gui,'left');
                yAxisPanel(gui,'right');
            end
            generalPanel(gui);
            if addColorMap
                colorMapPanel(gui);
            end
            
        end
        
    end
    
    % Set the window visible            
    set(gui.figureHandle,'visible','on');

end

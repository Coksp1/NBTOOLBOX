function setPlotOption(gui,~,event)
% Syntax:
%
% setPlotOption(gui,hObject,event)
%
% Description:
%
% Part of DAG. Set plot option for a variable
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    type    = get(event.NewValue,'string');
    oldType = get(event.OldValue,'string');

    % Update graph object properties
    %--------------------------------------------------
    plotterT = gui.plotter;
    string   = get(gui.popupmenu1,'string');
    index    = get(gui.popupmenu1,'value');
    var      = string{index};

    datesVsDates = 0;
    if isa(plotterT,'nb_graph_ts')
        if ~isempty(plotterT.datesToPlot)
            datesVsDates = 1;
        end
    end
    
    switch oldType

        case 'Not Plot'

            switch type

                case 'Right'

                    plotterT.variablesToPlotRight = [plotterT.variablesToPlotRight, var];

                case 'Left'

                    if datesVsDates
                        plotterT.datesToPlot     = [plotterT.datesToPlot, var];
                    else
                        plotterT.variablesToPlot = [plotterT.variablesToPlot, var];
                    end

            end

        case 'Right'

            switch type

                case 'Not Plot'

                    index                         = strcmp(var,plotterT.variablesToPlotRight);
                    plotterT.variablesToPlotRight = plotterT.variablesToPlotRight(~index);

                case 'Left'

                    index                         = strcmp(var,plotterT.variablesToPlotRight);
                    plotterT.variablesToPlotRight = plotterT.variablesToPlotRight(~index);
                    plotterT.variablesToPlot      = [plotterT.variablesToPlot, var];

            end

        case 'Left'

            switch type

                case 'Not Plot'

                    if datesVsDates
                        index                    = strcmp(var,plotterT.datesToPlot);
                        plotterT.datesToPlot     = plotterT.datesToPlot(~index);
                    else
                        index                    = strcmp(var,plotterT.variablesToPlot);
                        plotterT.variablesToPlot = plotterT.variablesToPlot(~index);
                    end

                case 'Right'

                    index                         = strcmp(var,plotterT.variablesToPlot);
                    plotterT.variablesToPlot      = plotterT.variablesToPlot(~index);
                    plotterT.variablesToPlotRight = [plotterT.variablesToPlotRight, var];

            end


    end

    % Update
    %--------------------------------------------------------------
    switch type

        case 'Not Plot'

            set(gui.uip,'visible','off');
            set(gui.popupmenu2,'enable','off') 
            
            % Notify listeners
            notify(gui,'changedGraph');

        case {'Left','Right'}

            % Update the panel with options and notify listeners
            set(gui.uip,'visible','on');
            updateGUI(gui,var,0)

    end

end

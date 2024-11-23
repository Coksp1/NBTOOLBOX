function setPlotType(gui,hObject,~)
% Syntax:
%
% setPlotType(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotter = gui.plotter;

    % Update the plot type
    plotType    = get(hObject,'tag');
    oldPlotType = plotter.plotType;
    if strcmpi(plotType,oldPlotType)
        return
    end
        
    plotter.set('plotType',plotType);
    type = class(plotter);

    % Update other settings dependent on the plot type
    %--------------------------------------------------------------
    if strcmpi(plotType,'scatter')

        err = switchToScatter(plotter,type);
        if err
            return
        end

    elseif strcmpi(plotType,'candle')

        err = switchToCandle(plotter);
        if err
            return
        end
        
    else
        switchToOthers(plotter,plotType)    
    end

    % Notify listeners
    notify(gui,'graphStyleChanged');
    
end

%==================================================================
% SUB
%==================================================================
function err = switchToScatter(plotter,type)

    err = 0;
    if strcmpi(type,'nb_graph_ts') || strcmpi(type,'nb_graph_data')
            
        if size(plotter.DB.variables,2) < 2
            nb_errorWindow('Cannot select scatter when less then 2 variables is found to be in the loaded dataset.')
            err = 1;
        end

        if strcmpi(type,'nb_graph_ts')
        
            if isempty(plotter.scatterDates) && isempty(plotter.scatterDatesRight)

                plotter.set('scatterVariables', plotter.DB.variables(1:2),...
                            'scatterDates',     {'scatterGroup1',{plotter.DB.startDate.toString(),plotter.DB.endDate.toString()}});

            end
            
        else % nb_graph_data
            
            if isempty(plotter.scatterObs) && isempty(plotter.scatterObsRight)

                plotter.set('scatterVariables', plotter.DB.variables(1:2),...
                            'scatterObs',       {'scatterGroup1',{plotter.DB.startObs,plotter.DB.endObs}});

            end
            
        end

    else % nb_graph_cs

        if size(plotter.DB.types,2) < 2
            nb_errorWindow('Cannot select scatter when less then 2 types is found to be in the loaded dataset.')
            err = 1;
        end

        if isempty(plotter.scatterVariables) && isempty(plotter.scatterVariablesRight)

            plotter.set('scatterVariables', {'scatterGroup1',plotter.DB.variables},...
                            'scatterTypes', plotter.DB.types(1:2));

        end

    end

end

%==========================================================================
function err = switchToCandle(plotter)

    err = 0;
    if size(plotter.DB.variables,2) < 2
        nb_errorWindow('Cannot select candle when less then 2 variables is found to be in the loaded dataset.')
        err = 1;
    end

    if isempty(plotter.candleVariables)

        plotter.set('candleVariables',  {'open',plotter.DB.variables{1},'close',plotter.DB.variables{2}});

    end

end

%==========================================================================
function switchToOthers(plotter,plotType)

    % Assign variables to plot if empty
    if isempty(plotter.variablesToPlot) && isempty(plotter.variablesToPlotRight)

        if plotter.DB.numberOfVariables > 10
            vars = plotter.DB.variables(1:10);
        else
            vars = plotter.DB.variables;
        end
        plotter.variablesToPlot = vars;

    end

    if strcmpi(plotType,'dec')

        % Must remove the individual plot types
        plotter.plotTypes = {};

    elseif strcmpi(plotType,'stacked')

        if ~isempty(plotter.plotTypes)

            % Must remove the individual plot types grouped
            ind = find(strcmpi('grouped',plotter.plotTypes));
            for ii = 1:size(ind,2)
                plotter.plotTypes = [plotter.plotTypes(1:ind(end - (ii - 1)) - 2), plotter.plotTypes(ind(end - (ii - 1)) + 1:end)];
            end

        end

    elseif strcmpi(plotType,'grouped')

        if ~isempty(plotter.plotTypes)

            % Must remove the individual plot types grouped
            ind = find(strcmpi('stacked',plotter.plotTypes));
            for ii = 1:size(ind,2)
                plotter.plotTypes = [plotter.plotTypes(1:ind(end - (ii - 1)) - 2), plotter.plotTypes(ind(end - (ii - 1)) + 1:end)];
            end

        end

    elseif strcmpi(plotType,'pie')

        if size(plotter.typesToPlot,2) > 1
            plotter.typesToPlot = plotter.typesToPlot(1);
        end
        
    elseif strcmpi(plotType,'donut')

        if size(plotter.typesToPlot,2) > 3
            plotter.typesToPlot = plotter.typesToPlot(1:3);
        end    

    end

end

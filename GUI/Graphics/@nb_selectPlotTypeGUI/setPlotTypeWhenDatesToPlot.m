function setPlotTypeWhenDatesToPlot(gui,hObject,~)
% Syntax:
%
% setPlotTypeWhenDatesToPlot(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% When we are dealing with Dates vs Dates plot this callback is called
% when switch plot types
%
% Only supported plot types is; stacked, grouped and line (also 
% splitted)
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

    % Update other settings dependent on the plot type
    %--------------------------------------------------------------
    switchToOthers(plotter,plotType)

    % Notify listeners
    notify(gui,'graphStyleChanged');
    
end

%==================================================================
% SUB
%==================================================================
function switchToOthers(plotter,plotType)

    % Assign variablesToPlot to plot if empty
%     if isempty(plotter.variablesToPlot) && isempty(plotter.variablesToPlotRight)
% 
%         if plotter.DB.numberOfVariables > 10
%             vars = plotter.DB.variables(1:10);
%         else
%             vars = plotter.DB.variables;
%         end
%         plotter.variablesToPlot = vars;
% 
%     end

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

    end

end

function plotter = checkObject(plotter,panel)
% Syntax:
%
% plotter = nb_importGraphGUI.checkObject(plotter,panel)
%
% Description:
%
% Part of DAG. We take for granted that some properties of the graph 
% object is on a given format. We check that the loaded object 
% fit these requirements.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        panel = false;
    end

    % Check for a empty object
    %--------------------------------------------------------------
    if isempty(plotter)
        if ~panel
            nb_errorWindow('The imported graph/table is empty. Nothing to graph.')
        end
        return
    elseif numel(plotter) > 1
        for ii = 1:numel(plotter)
            plotter(ii) = nb_importGraphGUI.checkObject(plotter(ii),panel);
        end
        return
    end

    % Check the graphMethod property
    %------------------------------------------------------
    if isa(plotter,'nb_graph')
        
        method = plotter.get('graphMethod');
        if ~strcmpi(method,'graph') && ~isempty(method)
            nb_errorWindow('The loaded graph uses the method graphInfoStruct or graphSubPlots, which is not supported.')
            return
        end

        % Check the colors property
        %------------------------------------------------------
        if isempty(plotter.colors) && ~isempty(plotter.colorOrder)

            datesVsDates = 0;
            if isa(plotter,'nb_graph_ts')
                if ~isempty(plotter.datesToPlot)
                    datesVsDates = 1;
                end
            end

            % The loaded object uses the colorOrder and/or 
            % colorOrderRight 
            if strcmpi(plotter.plotType,'scatter')

                if isa(plotter,'nb_graph_ts')

                    if ~isempty(plotter.scatterDatesRight)
                        nb_errorWindow('The scatterDatesRight property is not yet supported by the GUI.')
                        return
                    end

                    groups = plotter.scatterDates(1:2:end);

                elseif isa(plotter,'nb_graph_data')

                    if ~isempty(plotter.scatterObsRight)
                        nb_errorWindow('The scatterObsRight property is not yet supported by the GUI.')
                        return
                    end

                    groups = plotter.scatterObs(1:2:end);

                else

                    if ~isempty(plotter.scatterVariablesRight)
                        nb_errorWindow('The scatterVariablesRight property is not yet supported by the GUI.')
                        return
                    end

                    groups = plotter.scatterVariables(1:2:end);

                end

                cols = cell(1,size(groups,2)*2);
                kk   = 1;
                for ii = 1:size(groups,2)

                    cols{kk*2 - 1} = groups{ii};
                    if isnumeric(plotter.colorOrder)
                        cols{kk*2} = plotter.colorOrder(ii,:);
                    else
                        cols{kk*2} = plotter.colorOrder{ii};
                    end
                    kk = kk + 1;

                end

            elseif strcmpi(plotter.plotType,'candle')

                if isnumeric(plotter.colorOrder)
                    cols = {'candle',plotter.colorOrder(1,:)};
                else
                    cols = {'candle',plotter.colorOrder{1}};
                end

            elseif datesVsDates

                sLeft  = length(plotter.datesToPlot);
                cols   = cell(1,(sLeft)*2);
                dates  = plotter.datesToPlot;
                kk     = 1;
                for ii = 1:sLeft

                    cols{kk*2 - 1} = dates{ii};
                    if isnumeric(plotter.colorOrder)
                        cols{kk*2} = plotter.colorOrder(ii,:);
                    else
                        cols{kk*2} = plotter.colorOrder{ii};
                    end
                    kk = kk + 1;

                end

            else

                sLeft  = size(plotter.variablesToPlot,2);
                sRight = size(plotter.variablesToPlotRight,2);
                cols   = cell(1,(sLeft + sRight)*2);

                if isempty(plotter.colorOrder)
                    colorOrder = nb_defaultColors;
                else
                    colorOrder = plotter.colorOrder;
                end

                kk = 1;
                for ii = 1:sLeft

                    cols{kk*2 - 1} = plotter.variablesToPlot{ii};
                    if isnumeric(plotter.colorOrder)
                        cols{kk*2} = colorOrder(ii,:);
                    else
                        cols{kk*2} = colorOrder{ii};
                    end
                    kk = kk + 1;

                end

                if isempty(plotter.colorOrderRight)
                    colorOrderRight = nb_defaultColors;
                else
                    colorOrderRight = plotter.colorOrder;
                end

                for ii = 1:sRight

                    cols{kk*2 - 1} = plotter.variablesToPlotRight{ii};
                    if isnumeric(plotter.colorOrderRight)
                        cols{kk*2} = colorOrderRight(ii,:);
                    else
                        cols{kk*2} = colorOrderRight{ii};
                    end
                    kk = kk + 1;

                end

            end

            plotter.colors = cols;

        end

        % Check the highlight property
        %--------------------------------------------------------------
        if ~isempty(plotter.highlight)

            if ~iscell(plotter.highlight{1})
                plotter.highlight = {plotter.highlight};
            end

        end

        % Check the verticalLine property
        %--------------------------------------------------------------
        if ~isempty(plotter.verticalLine)

            if ischar(plotter.verticalLine)
                plotter.verticalLine = cellstr(plotter.verticalLine);
            elseif isnumeric(plotter.verticalLine)
                plotter.verticalLine = num2cell(plotter.verticalLine);
            end

        end

        % Check the bar shading date/obs property
        %-------------------------------------------------------------
        if isa(plotter,'nb_graph_ts')

            if ~isempty(plotter.barShadingDate)

                if ischar(plotter.barShadingDate) || isa(plotter.barShadingDate,'nb_date')

                    nVars  = length(plotter.variablesToPlot);
                    nVarsR = length(plotter.variablesToPlotRight);
                    bDates = cell(1,2*nVars + 2*nVarsR);
                    for ii = 1:nVars
                        bDates{ii*2-1} = plotter.variablesToPlot{ii};
                        bDates{ii*2}   = plotter.barShadingDate;
                    end
                    for ii = nVars + 1:nVars + nVarsR
                        bDates{ii*2-1} = plotter.variablesToPlotRight{ii};
                        bDates{ii*2}   = plotter.barShadingDate;
                    end
                    plotter.barShadingDate = bDates;

                end

            end

        elseif isa(plotter,'nb_graph_data')

            if ~isempty(plotter.barShadingObs)

                if ischar(plotter.barShadingObs) || isnumeric(plotter.barShadingObs)

                    nVars  = length(plotter.variablesToPlot);
                    nVarsR = length(plotter.variablesToPlotRight);
                    bObs = cell(1,2*nVars + 2*nVarsR);
                    for ii = 1:nVars
                        bObs{ii*2-1} = plotter.variablesToPlot{ii};
                        bObs{ii*2}   = plotter.barShadingObs;
                    end
                    for ii = nVars + 1:nVars + nVarsR
                        bObs{ii*2-1} = plotter.variablesToPlotRight{ii};
                        bObs{ii*2}   = plotter.barShadingObs;
                    end
                    plotter.barShadingObs = bObs;
                end

            end

        end

        % Get the legend information (The GUI uses the legendText property 
        % instead of the legends property)
        %-----------------------------------------------------------------
        updateLegendInformation(plotter);
        plotter.legAuto = 'on';
        
    end
    
end

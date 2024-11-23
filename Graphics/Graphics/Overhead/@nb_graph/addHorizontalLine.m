function addHorizontalLine(obj)
% Syntax:
%
% addHorizontalLine(obj)
%
% Description:
%
% Add horizontal line to current graph. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen 
            
    if any(strcmpi(obj.plotType,{'radar','image'}))
        return
    end

    if ~isempty(obj.horizontalLine)

        if ischar(obj.horizontalLineStyle)
            obj.horizontalLineStyle = {obj.horizontalLineStyle};
        end

        if ~iscell(obj.horizontalLineColor)
            obj.horizontalLineColor = {obj.horizontalLineColor};
        end

        numberOfHorLine = length(obj.horizontalLine);
        numbOfColors    = size(obj.horizontalLineColor,2);
        numbOfStyles    = size(obj.horizontalLineStyle,2);

        % Ensure that the 'horizontalLineColor' property has the
        % same number of elements as the 'horizontalLine' property
        %----------------------------------------------------------
        if numberOfHorLine > numbOfColors

            % Set the default color of all the horizontal lines
            % which doesn't have a color
            diff          = numberOfHorLine - numbOfColors;
            defaultColors = cell(1,diff);
            for ii = 1:diff
                defaultColors{ii} = [51 51 51]/256;
            end
            obj.horizontalLineColor = [obj.horizontalLineColor, defaultColors];

        end

        % Ensure that the 'horizontalLineStyle' property has the
        % same number of elements as the 'horizontalLine' property
        %----------------------------------------------------------
        if numberOfHorLine > numbOfStyles

            % Set the default color of all the horizontal lines
            % which doesn't have a color
            diff          = numberOfHorLine - numbOfStyles;
            defaultStyles = cell(1,diff);
            for ii = 1:diff
                defaultStyles{ii} = '-';
            end
            obj.horizontalLineStyle = [obj.horizontalLineStyle, defaultStyles];

        end

        % Plot all the horizontal lines
        %----------------------------------------------------------
        if isa(obj,'nb_graph_cs')

            if strcmpi(obj.barOrientation,'horizontal')

                for ii = 1:numberOfHorLine

                    color = obj.horizontalLineColor{ii};
                    style = obj.horizontalLineStyle{ii};
                    nb_verticalLine(obj.horizontalLine(ii),...
                                    'parent',     obj.axesHandle,...
                                    'lineStyle',  style,...
                                    'cData',      color,...
                                    'linewidth',  obj.horizontalLineWidth);

                end

            else

                for ii = 1:numberOfHorLine

                    color = obj.horizontalLineColor{ii};
                    style = obj.horizontalLineStyle{ii};
                    nb_horizontalLine(obj.horizontalLine(ii),...
                                      'parent',     obj.axesHandle,...
                                      'lineStyle',  style,...
                                      'cData',      color,...
                                      'linewidth',  obj.horizontalLineWidth);

                end

            end

        else

            for ii = 1:numberOfHorLine

                color = obj.horizontalLineColor{ii};
                style = obj.horizontalLineStyle{ii};
                nb_horizontalLine(obj.horizontalLine(ii),...
                                  'parent',     obj.axesHandle,...F
                                  'lineStyle',  style,...
                                  'cData',      color,...
                                  'linewidth',  obj.horizontalLineWidth);

            end

        end

    end

end

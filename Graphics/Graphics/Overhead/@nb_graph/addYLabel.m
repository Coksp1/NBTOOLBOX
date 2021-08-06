function addYLabel(obj)
% Syntax:
%
% addYLabel(obj)
%
% Description:
%
% Add y-label to current graph. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen         

    % Find out the y-axis label, if not given
    %--------------------------------------------------------------
    switch lower(obj.graphMethod)

        case 'graphinfostruct'

            if ~isempty(obj.inputs.yLabel)
                yLab = obj.inputs.yLabel;
            else
                yLab = obj.yLabel;
            end

            if ~isempty(obj.inputs.yLabelRight)
                yLabR = obj.inputs.yLabelRight;
            else
                yLabR = obj.yLabelRight;
            end

        otherwise

            yLab  = obj.yLabel;
            yLabR = obj.yLabelRight;
    end

    % Plot the y-axis label
    %--------------------------------------------------------------
    if ~obj.noLabel

        if ~isempty(yLab)

            if ~isempty(obj.lookUpMatrix)
                yLab = nb_graph.findVariableName(obj,yLab);
            end

            if ~isempty(obj.localVariables)
                yLab = nb_localVariables(obj.localVariables,yLab);
            end
            yLab = nb_localFunction(obj,yLab);

            lab             = nb_ylabel();
            lab.parent      = obj.axesHandle;
            lab.string      = yLab;
            lab.fontName    = obj.fontName;
            lab.fontSize    = obj.yLabelFontSize;
            lab.fontUnits   = obj.fontUnits;
            lab.fontWeight  = obj.yLabelFontWeight;
            lab.interpreter = obj.yLabelInterpreter;
            lab.normalized  = obj.normalized;
            obj.axesHandle.addYLabel(lab);

        end

        if ~isempty(yLabR)

            if ~isempty(obj.lookUpMatrix)
                yLabR = nb_graph.findVariableName(obj,yLabR);
            end

            if ~isempty(obj.localVariables)
                yLabR = nb_localVariables(obj.localVariables,yLabR);
            end
            yLabR = nb_localFunction(obj,yLabR);

            lab             = nb_ylabel();
            lab.parent      = obj.axesHandle;
            lab.string      = yLabR;
            lab.fontName    = obj.fontName;
            lab.fontSize    = obj.yLabelFontSize;
            lab.fontUnits   = obj.fontUnits;
            lab.fontWeight  = obj.yLabelFontWeight;
            lab.interpreter = obj.yLabelInterpreter;
            lab.normalized  = obj.normalized;
            lab.side        = 'right';
            obj.axesHandle.addYLabel(lab);

        end

    end

end

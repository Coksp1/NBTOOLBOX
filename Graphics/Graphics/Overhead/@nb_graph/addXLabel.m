function addXLabel(obj)
% Syntax:
%
% addXLabel(obj)
%
% Description:
%
% Add x-label to current graph. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen 
              
    if ~obj.noLabel

        switch obj.graphMethod

            case 'graphinfostruct'

                if isempty(obj.inputs.xLabel)                           
                    xLab = ''; 
                else
                    xLab = obj.inputs.xLabel; 
                end

            otherwise

                xLab = obj.xLabel;
        end

        if ~isempty(xLab)

            if ~isempty(obj.lookUpMatrix)
                xLab = nb_graph.findVariableName(obj,xLab);
            end

            if ~isempty(obj.localVariables)
                 xLab = nb_localVariables(obj.localVariables,xLab);
            end
            xLab = nb_localFunction(obj,xLab);

            lab = nb_xlabel();
            lab.parent      = obj.axesHandle;
            lab.string      = xLab;
            lab.alignment   = obj.xLabelAlignment;
            lab.fontName    = obj.fontName;
            lab.fontSize    = obj.xLabelFontSize;
            lab.fontUnits   = obj.fontUnits;
            lab.fontWeight  = obj.xLabelFontWeight;
            lab.interpreter = obj.xLabelInterpreter;
            lab.normalized  = obj.normalized;
            lab.placement   = obj.xLabelPlacement;
            obj.axesHandle.addXLabel(lab);

        end

    end

end

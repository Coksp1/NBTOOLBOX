function addTitle(obj)
% Syntax:
%
% addTitle(obj)
%
% Description:
%
% Add title to current graph. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen          

    if obj.noTitle ~= 1

        switch lower(obj.graphMethod)

            case 'graphinfostruct'

                if isempty(obj.inputs.title)
                    tit = obj.GraphStruct.(obj.fieldName){obj.fieldIndex,1};
                else
                    tit = obj.inputs.title;
                end

                if ~isempty(obj.lookUpMatrix)
                    tit = nb_graph.findVariableName(obj,tit);
                end

            otherwise

                if iscellstr(obj.title) && obj.numberOfGraphs > 1
                    try
                        tit = obj.title{obj.subPlotIndex};
                    catch %#ok<CTCH>
                        tit = ''; 
                    end
                else 
                    tit = obj.title;
                end
                if ~isempty(obj.lookUpMatrix)
                    tit = nb_graph.findVariableName(obj,tit); 
                end

        end

        if strcmpi(obj.graphMethod,'graph') && obj.noTitle == 2
            tit = obj.DB.dataNames{obj.subPlotIndex};
        end

        %--------------------------------------------------
        % Plot the title
        %--------------------------------------------------
        if ~isempty(obj.localVariables)
             tit = nb_localVariables(obj.localVariables,tit);
        end
        tit           = nb_localFunction(obj,tit);
        t             = nb_title();
        t.parent      = obj.axesHandle;
        t.string      = tit;
        t.alignment   = obj.titleAlignment;
        t.fontName    = obj.fontName;
        t.fontSize    = obj.titleFontSize;
        t.fontUnits   = obj.fontUnits;
        t.fontWeight  = obj.titleFontWeight;
        t.interpreter = obj.titleInterpreter;
        t.normalized  = obj.normalized;
        t.placement   = obj.titlePlacement;
        obj.axesHandle.addTitle(t);

    end

end

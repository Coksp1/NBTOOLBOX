function addFigureTitle(obj)
% Syntax:
%
% addFigureTitle(obj)
%
% Description:
%
% Add figure title to current graph. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen         

    if nb_isOneLineChar(obj.figureTitle)

        fontSize = obj.titleFontSize;
        if strcmpi(obj.fontUnits,'normalized')
            axPos    = obj.axesHandle.position;
            fontSize = fontSize/axPos(4);
        end

        nb_figureTitle(obj.figureTitle,...
               'fontName',      obj.fontName,...
               'fontSize',      fontSize,...
               'fontUnits',     obj.fontUnits,...
               'fontWeight',    obj.titleFontWeight,...
               'interpreter',   obj.titleInterpreter,...
               'parent',        obj.figureHandle(obj.fieldIndex),...
               'placement',     'center',...
               'interpreter',   'none');

    elseif obj.figureTitle

        fontSize = obj.titleFontSize;
        if strcmpi(obj.fontUnits,'normalized')
            axPos    = obj.axesHandle.position;
            fontSize = fontSize/axPos(4);
        end

        fnames = fieldnames(obj.GraphStruct);
        fname  = obj.fieldName;
        id     = find(strcmp(fname,fnames),1);
        if ~isempty(obj.lookUpMatrix)
            fname  = nb_graph.findVariableName(obj,fname);
        end
        nb_figureTitle(fname,...
               'fontName',      obj.fontName,...
               'fontSize',      fontSize,...
               'fontUnits',     obj.fontUnits,...
               'fontWeight',    obj.titleFontWeight,...
               'interpreter',   obj.titleInterpreter,...
               'parent',        obj.figureHandle(id),...
               'placement',     'center',...
               'interpreter',   'none');

    end

end

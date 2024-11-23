function addBaseLine(obj)
% Syntax:
%
% addBaseLine(obj)
%
% Description:
%
% Add base line to current graph. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen          

    if any(strcmpi(obj.plotType,{'radar','image'}))
        return
    end

    if obj.baseLine && ~ischar(obj.baseValue)

        if isa(obj,'nb_graph_ts') || isa(obj,'nb_graph_data') || isa(obj,'nb_graph_bd')

            nb_horizontalLine(obj.baseValue,...
                              'parent',     obj.axesHandle,...
                              'cData',      obj.baseLineColor,...
                              'lineStyle',  obj.baseLineStyle,...
                              'lineWidth',  obj.baseLineWidth);

        else

            if strcmpi(obj.barOrientation,'horizontal')

                nb_verticalLine(obj.baseValue,...
                                'parent',     obj.axesHandle,...
                                'cData',      obj.baseLineColor,...
                                'lineStyle',  obj.baseLineStyle,...
                                'lineWidth',  obj.baseLineWidth);

            else

                nb_horizontalLine(obj.baseValue,...
                                  'parent',     obj.axesHandle,...
                                  'cData',      obj.baseLineColor,...
                                  'lineStyle',  obj.baseLineStyle,...
                                  'lineWidth',  obj.baseLineWidth);

            end

        end

    end

end

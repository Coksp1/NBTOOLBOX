function applyNotTickOptions(obj)
% Syntax:
%
% applyNotTickOptions(obj)
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen 

    if obj.noTickMarkLabels 
        obj.axesHandle.xTick         = [];
        obj.axesHandle.yTick         = [];
        obj.axesHandle.yTickSet      = 1;
        obj.axesHandle.yTickRight    = [];
        obj.axesHandle.yTickRightSet = 1;
        obj.axesHandle.xTickVisible  = false;
        obj.axesHandle.yTickVisible  = false;
    end
    if obj.noTickMarkLabelsRight
        obj.axesHandle.yTickRight    = [];
        obj.axesHandle.yTickRightSet = 1;
    end
    if obj.noTickMarkLabelsLeft
        obj.axesHandle.yTick    = [];
        obj.axesHandle.yTickSet = 1;
    end

end

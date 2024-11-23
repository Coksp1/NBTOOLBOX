function applyNotTickOptions(obj)
% Syntax:
%
% applyNotTickOptions(obj)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen 

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

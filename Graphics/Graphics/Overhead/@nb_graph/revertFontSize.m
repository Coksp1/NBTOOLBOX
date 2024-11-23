function revertFontSize(obj,oldFontSizes)
% Syntax:
%
% revertFontSize(obj,oldFontSizes)
%
% Description:
%
% Inverse of the adjustFontSize method
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen 

    obj.axesFontSize   = oldFontSizes(1);
    obj.titleFontSize  = oldFontSizes(2);
    obj.xLabelFontSize = oldFontSizes(3);
    obj.yLabelFontSize = oldFontSizes(4);
    obj.legFontSize    = oldFontSizes(5);

end

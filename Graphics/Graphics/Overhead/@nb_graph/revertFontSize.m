function revertFontSize(obj,oldFontSizes)
% Syntax:
%
% revertFontSize(obj,oldFontSizes)
%
% Description:
%
% Inverse of the adjustFontSize method
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen 

    obj.axesFontSize   = oldFontSizes(1);
    obj.titleFontSize  = oldFontSizes(2);
    obj.xLabelFontSize = oldFontSizes(3);
    obj.yLabelFontSize = oldFontSizes(4);
    obj.legFontSize    = oldFontSizes(5);

end

function oldFontSizes = scaleFontSize(obj)
% Syntax:
%
% oldFontSizes = scaleFontSize(obj)
%
% Description:
%
% Scale the font size
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen 

    % Return the old font sizes
    oldFontSizes    = nan(5,1);
    oldFontSizes(1) = obj.axesFontSize;
    oldFontSizes(2) = obj.titleFontSize;
    oldFontSizes(3) = obj.xLabelFontSize;
    oldFontSizes(4) = obj.yLabelFontSize;
    oldFontSizes(5) = obj.legFontSize;

    % Adjust the font sizes temporarily
    fac                = obj.fontScale;
    obj.axesFontSize   = obj.axesFontSize*fac;
    obj.titleFontSize  = obj.titleFontSize*fac;
    obj.xLabelFontSize = obj.xLabelFontSize*fac;
    obj.yLabelFontSize = obj.yLabelFontSize*fac;
    obj.legFontSize    = obj.legFontSize*fac;

end

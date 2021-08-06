function oldFontSizes = adjustFontSize(obj,subplotsize)
% Syntax:
%
% oldFontSizes = adjustFontSize(obj,subplotsize)
%
% Description:
%
% Adjust the font size given the subplot size
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen 

    if nargin < 2
        subplotsize = obj.subPlotSize;
    end

    % Return the old font sizes
    oldFontSizes    = nan(4,1);
    oldFontSizes(1) = obj.axesFontSize;
    oldFontSizes(2) = obj.titleFontSize;
    oldFontSizes(3) = obj.xLabelFontSize;
    oldFontSizes(4) = obj.yLabelFontSize;
    oldFontSizes(5) = obj.legFontSize;

    % Adjust the font sizes temporarily
    if subplotsize(1) > 1 && (strcmpi(obj.graphStyle,'presentation') || strcmpi(obj.graphStyle,'presentation_white'))
        % Make the font smaller then the default for
        % a graph with subplot size equal to [1,1]
        fac = 0.7*obj.fontScale;               
    else  
        fac = obj.fontScale;
    end

    % Scale the font size temporarily
    obj.axesFontSize   = obj.axesFontSize*fac;
    obj.titleFontSize  = obj.titleFontSize*fac;
    obj.xLabelFontSize = obj.xLabelFontSize*fac;
    obj.yLabelFontSize = obj.yLabelFontSize*fac;
    obj.legFontSize    = obj.legFontSize*fac;

end

function loc = nb_findColor(color,colors)
% Syntax:
%
% loc = nb_findColor(color,colors)
%
% Description:
%
% Find color among a set of colors stored in a cell array.
% 
% Input:
% 
% - color  : Either a 1 x 3 double array with the RGB colors, or a one 
%            line char with the color name.
%
%            See nb_plotHandle.interpretColor for supported color names.
% 
% - colors : A N x 1 cell array with colors on the one of the formats
%            described for the color input.
%
% Output:
% 
% - loc    : The location of color in colors. 0 is returned if not found.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ischar(color)
        loc = find(strcmpi(color,colors),1);
        if isempty(loc)
            loc = 0;
        end
    else
        isChar           = cellfun(@ischar,colors);
        colorsD          = colors(~isChar); 
        colorsD          = vertcat(colorsD{:});
        ind              = ismember(colorsD, color,'rows');
        fullInd          = false(size(colors,1),1);
        fullInd(~isChar) = ind;
        loc              = find(fullInd,1);
        if isempty(loc)
            loc = 0;
        end
    end
    

end

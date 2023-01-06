function nb_colormap(ax,map)
% Syntax:
%
% nb_colormap(ax,map)
%
% Description:
%
% Set the color map used by an object of class nb_axes. The color map
% of an nb_axes object may be used when a nb_image object assign the 
% nb_axes object as it parent.
% 
% Input:
% 
% - ax : An object of class nb_axes.
%
% - map : A n x 3 double with the color map to use.
% 
% See also:
% nb_axes.colorMap, nb_axes.set
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    set(ax,'colorMap',map);

end

function cell = nb_emptyCell(parent)
% Syntax:
%
% cell = nb_emptyCell(parent)
%
% Description:
%
% Add empty cell to nb_gridcontainer object.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    color = get(parent,'backgroundColor');
    cell  = uicontrol(parent, 'Style', 'text', 'String', '',...
                     'backgroundColor', color);
    
end

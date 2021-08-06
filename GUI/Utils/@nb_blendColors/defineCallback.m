function defineCallback(gui,~,~)
% Syntax:
%
% defineCallback(gui,h,e)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Let the user select a color
    h     = nb_defineColor();
    color = h.getColor();
    
    % Assign it to the default colors
    add2Colors(gui,color);

end

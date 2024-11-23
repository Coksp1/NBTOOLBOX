function defineCallback(gui,~,~)
% Syntax:
%
% defineCallback(gui,h,e)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Let the user select a color
    h     = nb_defineColor();
    color = h.getColor();
    
    % Assign it to the default colors
    add2Colors(gui,color);

end

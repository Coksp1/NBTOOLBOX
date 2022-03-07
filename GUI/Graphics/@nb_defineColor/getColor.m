function color = getColor(gui)
% Syntax:
%
% color = getColor(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen        

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Wait for the window to close
    uiwait(gui.figureHandle);
    
    % Get the color selected
    color = gui.color;
            
end

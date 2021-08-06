function color = getColor(gui)
% Syntax:
%
% color = getColor(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen        

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Wait for the window to close
    uiwait(gui.figureHandle);
    
    % Get the color selected
    color = gui.color;
            
end

function makeFanVariablesGUI(gui)
% Syntax:
%
% makeFanVariablesGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
        
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Create the main window
    %--------------------------------------------------------------
    gui.figureHandle = nb_guiFigure(gui.plotter.parent,'Fan Chart Properties',[40   15  85.5   31.5],'modal','off');
    
    % Make sub-windows            
    selectVariablesPanel(gui)
    propertiesPanel(gui)
    
    % Set the window visible            
    set(gui.figureHandle,'visible','on');

end

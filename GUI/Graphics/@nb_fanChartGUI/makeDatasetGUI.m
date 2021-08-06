function makeDatasetGUI(gui)
% Syntax:
%
% makeDatasetGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen
        
% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Create the main window
    %------------------------------------------------------
    gui.figureHandle = nb_guiFigure(gui.plotter.parent,'Fan Chart Properties',[40   15  85.5   31.5],'modal','off');               
    
    % Make sub-windows            
    selectDatasetPanel(gui)
    propertiesPanel(gui)
    
    % Set the window visible            
    set(gui.figureHandle,'visible','on');

end

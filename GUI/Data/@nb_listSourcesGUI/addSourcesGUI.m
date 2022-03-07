function addSourcesGUI(gui)
% Syntax:
%
% addSourcesGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    f = gui.figureHandle;
    
    % Correct the name if user changed object
    name       = gui.name;    
    parentName = [gui.parent.guiName,': '];
    f.Name     = [parentName,name];
    
    % Get list of sources of active graph
    src = fieldnames(gui.sources.(name));

    % Populate the source section
    uicontrol(f,nb_constant.LABEL,...
                'string','Choose source',...
                'position',[0.03,0.80,0.40,0.10],...
                'fontweight','bold');
            
    uicontrol(f,nb_constant.POPUP,...
                'string',src,...
                'position',[0.345,0.80,0.31,0.10],...
                'callback',@gui.changeSource);
    
    fillPanelGUI(gui);
    
end

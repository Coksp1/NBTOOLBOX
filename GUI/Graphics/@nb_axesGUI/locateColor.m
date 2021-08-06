function [endc,value] = locateColor(gui)
% Syntax:
%
% [endc,value] = locateColor(gui)
%
% Description:
%
% Locate or give default color to the pie edge color.
% 
% Input:
% 
% - gui   : Either an object of class nb_GUI or an object that has a 
%           property defaultColors.
% 
% Output:
% 
% - endc  : A N x 3 double.
%
% - value : Index of the color of the variable in endc.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    parent   = plotterT.parent;
    endc     = nb_getGUIColorList(gui,parent);
    
    try
    
        % Locate the selected color in the color list
        colorTemp = plotterT.pieEdgeColor;
        if ischar(colorTemp)
            if strcmpi(colorTemp,'none')
                value = 0; 
                return
            end
        end
        value = nb_findColor(colorTemp,endc);
        if value == 0
            [endc,value] = nb_addColor(gui,parent,endc,colorTemp);
        end
        
    catch %#ok<CTCH>
        value = 0; % Defaults to 'none'
    end

end

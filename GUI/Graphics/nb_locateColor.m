function [endc,value] = nb_locateColor(gui,variable)
% Syntax:
%
% [endc,value] = nb_locateColor(gui,variable)
%
% Description:
%
% Locate or give default color to the variable, will also add the loaded
% object colors to the default colors of eiter the local window or the
% NB GUI.
% 
% Input:
% 
% - gui      : Either an object that has a nb_graph object stored as the
%              plotter property. If the parent of the that object is not
%              an object of class nb_GUI, it also need a proeprty 
%              defaultColors.
%               
% - variable : The name of the variable to locate or give a defualt color
%              of.
% 
% Output:
% 
% - endc     : A N x 3 double.
%
% - value    : Index of the color of the variable in endc.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    parent   = plotterT.parent;
    endc     = nb_getGUIColorList(gui,parent);
    try
    
        col  = plotterT.colors;
        ind  = find(strcmpi(variable,col),1,'last');
        if isempty(ind)
            % Get the prefered default color
            value           = nb_findGUIDefaultColor(endc,col(2:2:end));
            plotterT.colors = [col,variable,endc{value}];
        else
            % Locate the selected color in the color list
            colorTemp = col{ind + 1};
            value     = nb_findColor(colorTemp,endc);
            if value == 0
                [endc,value] = nb_addColor(gui,parent,endc,colorTemp);
            end
        end
        
    catch %#ok<CTCH>
        value = 1;
    end

end

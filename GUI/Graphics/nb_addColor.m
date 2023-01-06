function [endc,value] = nb_addColor(gui,parent,endc,colorTemp)
% Syntax:
%
% [endc,value] = nb_addColor(gui,parent,endc,colorTemp)
%
% Description:
%
% Add color to default colors.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    endc  = [endc;{colorTemp}];
    value = size(endc,1);

    % Add it to the default colors
    if isa(parent,'nb_GUI')
        parent.settings.defaultColors = endc;
    else
        gui.defaultColors = endc;
    end
    
end

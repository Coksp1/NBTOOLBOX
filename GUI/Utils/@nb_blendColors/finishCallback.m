function finishCallback(gui,~,~)
% Syntax:
%
% finishCallback(gui,h,e)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the blending options
    alpha1 = nb_getUIControlValue(gui.components.alpha1,'numeric');
    if ~nb_isScalarNumberClosed(alpha1,0,1)
        nb_errorWindow('Alpha 1 must be a number between 0 and 1.')
    end
    
    alpha2 = nb_getUIControlValue(gui.components.alpha2,'numeric');
    if ~nb_isScalarNumberClosed(alpha2,0,1)
        nb_errorWindow('Alpha 2 must be a number between 0 and 1.')
    end
    
    % Get the colors to blend
    index1 = get(gui.components.color1,'value');
    index2 = get(gui.components.color2,'value');
    color1 = gui.colors(index1,:);
    color2 = gui.colors(index2,:);
    
    % Do the blending
    newColor = nb_alpha(color1,color2,alpha1,alpha2);
    
    % Assign it to the default colors
    add2Colors(gui,newColor);
    
end

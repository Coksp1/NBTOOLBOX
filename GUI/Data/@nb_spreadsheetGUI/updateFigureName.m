function updateFigureName(gui)
% Syntax:
%
% updateFigureName(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(gui.parent,'nb_GUI') 
        name = [gui.parent.guiName ': ' gui.figureName]; 
    else
        name = gui.figureName;
    end

    set(gui.figureHandle,'name',name);  

end

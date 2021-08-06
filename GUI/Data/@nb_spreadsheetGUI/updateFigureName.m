function updateFigureName(gui)
% Syntax:
%
% updateFigureName(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if isa(gui.parent,'nb_GUI') 
        name = [gui.parent.guiName ': ' gui.figureName]; 
    else
        name = gui.figureName;
    end

    set(gui.figureHandle,'name',name);  

end

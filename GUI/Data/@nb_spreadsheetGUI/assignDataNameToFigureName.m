function assignDataNameToFigureName(gui)
% Syntax:
%
% assignDataNameToFigureName(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    current      = get(gui.figureHandle,'name'); 
    index        = strfind(current,':');
    if length(index) > 1
        newName = [current(1:index(end)) ' ' gui.dataName];
    else
        newName = [current ': ' gui.dataName];
    end
    set(gui.figureHandle,'name',newName); 

end

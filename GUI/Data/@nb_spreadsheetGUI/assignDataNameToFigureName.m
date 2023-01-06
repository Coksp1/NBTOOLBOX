function assignDataNameToFigureName(gui)
% Syntax:
%
% assignDataNameToFigureName(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    current      = get(gui.figureHandle,'name'); 
    index        = strfind(current,':');
    if length(index) > 1
        newName = [current(1:index(end)) ' ' gui.dataName];
    else
        newName = [current ': ' gui.dataName];
    end
    set(gui.figureHandle,'name',newName); 

end

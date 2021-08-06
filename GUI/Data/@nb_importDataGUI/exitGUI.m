function exitGUI(gui,hObject,~)
% Syntax:
%
% exitGUI(gui,hObject,event)
%
% Description:
%
% Part of DAG. Exit without doing anything
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isempty(gui.excel)
       Workbook = gui.excel.Workbooks.Item(1);
       Workbook.Close(false);
       Quit(gui.excel); 
    end

    % Close parent (I.e. the GUI)
    if isempty(gui.figureHandle)
        close(get(hObject,'parent'))
    else
        close(gui.figureHandle)
    end
    
end 

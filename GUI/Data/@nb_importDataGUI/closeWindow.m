function closeWindow(gui,~,~)
% Syntax:
%
% closeWindow(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

   close(gui.figureHandle)
   
   % We must also quit the Excel application if it is open 
   if ~isempty(gui.excel)
       Workbook = gui.excel.Workbooks.Item(1);
       Workbook.Close(false);
       Quit(gui.excel); 
   end
   
end

function close(~,hObject,~)
% Syntax:
%
% close(gui,hObject,event)
%
% Description:
%
% Part of DAG. Close request callback called when user try to close 
% spreadsheet window
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    delete(hObject);

end

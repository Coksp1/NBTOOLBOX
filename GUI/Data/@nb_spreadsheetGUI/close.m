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
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    delete(hObject);

end

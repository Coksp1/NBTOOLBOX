function exit(~,hObject,~)
% Syntax:
%
% exit(gui,hObject,event)
%
% Description:
%
% Part of DAG. Exit without doing anything
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Close parent (I.e. the GUI)
    close(get(hObject,'parent'));

end 

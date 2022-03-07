function exit(~,hObject,~)
% Syntax:
%
% exit(gui,hObject,event)
%
% Description:
%
% Part of DAG. Exit without doing anything
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Close parent (I.e. the GUI)
    close(get(hObject,'parent'));

end 

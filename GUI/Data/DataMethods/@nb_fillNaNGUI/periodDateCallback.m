function periodDateCallback(gui,hObject,~)
% Syntax:
%
% periodDateCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if get(hObject,'value')
        string = 'Periods from today';
    else
        string = 'Date';
    end
    set(gui.components.text1,'string',string);

end


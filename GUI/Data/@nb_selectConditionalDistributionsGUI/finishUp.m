function finishUp(gui,hObject,~)
% Syntax:
%
% finishUp(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    delete(gui.figureHandle);
    delete(get(hObject,'parent'))
    
end

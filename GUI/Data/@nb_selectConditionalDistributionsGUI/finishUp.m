function finishUp(gui,hObject,~)
% Syntax:
%
% finishUp(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    delete(gui.figureHandle);
    delete(get(hObject,'parent'))
    
end

function close(gui,~,~)
% Syntax:
%
% close(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    delete(gui.components.figureHandle);
    
end

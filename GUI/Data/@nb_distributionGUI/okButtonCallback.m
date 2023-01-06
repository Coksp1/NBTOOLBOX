function okButtonCallback(gui, ~, ~)
% Syntax:
%
% okButtonCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    close(gui.figureHandle);
    notify(gui, 'done');
    
end

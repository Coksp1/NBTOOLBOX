function okButtonCallback(gui, ~, ~)
% Syntax:
%
% okButtonCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    close(gui.figureHandle);
    notify(gui, 'done');
    
end

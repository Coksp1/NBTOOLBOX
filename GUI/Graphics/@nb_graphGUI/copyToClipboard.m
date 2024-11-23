function copyToClipboard(gui,~,~)
% Syntax:
%
% copyToClipboard(gui,hObject,event)
%
% Description:
%
% Part of DAG. Copy figure to clipboard
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    set(gui.figureHandle.figureHandle,'PaperPositionMode','auto',...
                                      'renderer',         'painters', ...
                                      'invertHardcopy',   'off');
    print(gui.figureHandle.figureHandle,'-dmeta');%

end

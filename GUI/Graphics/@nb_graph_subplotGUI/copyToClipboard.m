function copyToClipboard(gui,~,~)
% Syntax:
%
% copyToClipboard(gui,hObject,event)
%
% Description:
%
% Part of DAG. Copy figure to clipboard
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    set(gui.figureHandle.figureHandle,'PaperPositionMode','auto',...
                                      'renderer',         'painters', ...
                                      'invertHardcopy',   'off');
    print(gui.figureHandle.figureHandle,'-dbitmap');%dmeta

end

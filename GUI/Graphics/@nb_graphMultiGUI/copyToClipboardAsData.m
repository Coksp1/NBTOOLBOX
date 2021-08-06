function copyToClipboardAsData(gui,~,~)
% Syntax:
%
% copyToClipboardAsData(gui,hObject,event)
%
% Description:
%
% Part of DAG. Copy figure data to clipboard
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    data = getData(gui.plotter(gui.page));
    data = asCell(data);
    nb_copyToClipboard(data);

end

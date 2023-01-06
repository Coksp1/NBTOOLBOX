function copyToClipboardAsData(gui,~,~)
% Syntax:
%
% copyToClipboardAsData(gui,hObject,event)
%
% Description:
%
% Part of DAG. Copy figure data to clipboard
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    data = getData(gui.plotter(gui.page));
    data = asCell(data);
    nb_copyToClipboard(data);

end

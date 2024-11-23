function copyToClipboardAsData(gui,hObject,~)
% Syntax:
%
% copyToClipboardAsData(gui,hObject,event)
%
% Description:
%
% Part of DAG. Copy figure data to clipboard
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if strcmpi(gui.type,'advanced')
        if size(gui.plotterAdv.plotter,2) > 1
            index = get(hObject,'userData');
            data  = getData(gui.plotterAdv.plotter(index));
        else
            data = getData(gui.plotter);
        end
    else
        data = getData(gui.plotter);
    end
    data = asCell(data);
    nb_copyToClipboard(data);

end

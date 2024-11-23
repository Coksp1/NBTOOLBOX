function xTickLabelsEdit(gui,hObject,event)
% Syntax:
%
% xTickLabelsEdit(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotter = gui.plotter;

    if isempty(event.Error)

        data                 = get(hObject,'data');
        xTickLabels          = cell(1,size(data,1)*2);
        xTickLabels(1:2:end) = data(:,1)';
        xTickLabels(2:2:end) = data(:,2)';
        plotter.set('xTickLabels',xTickLabels);

        % Udate the graph
        notify(gui,'changedGraph');

    else
        nb_errorWindow('Error while edit the selected cell of the table') 
    end

end

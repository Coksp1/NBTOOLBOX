function cellEdit(gui,hObject,event)
% Syntax:
%
% cellEdit(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback function when editing the legends  
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotter = gui.plotter;

    if isempty(event.Error)

        if event.Indices(2) == 2

            data           = get(hObject,'data');
            newInd         = data(:,2);
            newInd         = cell2mat(newInd);
            types          = plotter.DB.types;
            newTypesToPlot = types(newInd);
            plotter.set('typesToPlot',newTypesToPlot);

            % Udate the graph
            notify(gui,'changedGraph');
            
        elseif event.Indices(2) == 3
            
            data            = get(hObject,'data');
            newInd          = data(:,3);
            newInd          = cell2mat(newInd);
            types           = plotter.DB.types;
            newTypesToPlotR = types(newInd);
            plotter.set('typesToPlotRight',newTypesToPlotR);

            % Udate the graph
            notify(gui,'changedGraph');

        end

    else
        nb_errorWindow('Error while edit the selected cell of the table') 
    end

end

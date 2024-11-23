function typesOfTableEdit(gui,hObject,event)
% Syntax:
%
% typesOfTableEdit(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotter = gui.plotter;

    if isempty(event.Error)

        if event.Indices(2) == 2

            data     = get(hObject,'data');
            newInd   = data(:,2);
            newInd   = cell2mat(newInd);
            types    = plotter.DB.types;
            newTypes = types(newInd);
            plotter.set('typesOfTable',newTypes);

            % Udate the graph
            notify(gui,'changedGraph');

        end

    else
        nb_errorWindow('Error while edit the selected cell of the table') 
    end

end

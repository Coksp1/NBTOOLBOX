function cellEdit(gui,hObject,event)
% Syntax:
%
% cellEdit(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen   

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    if isempty(event.Error)

            ind1 = event.Indices(1);
            ind2 = event.Indices(2);
        
            % Assign changes
            ed  = event.EditData;
            ind = strfind(ed,'\\');
            if isempty(ind)
                new = ed;
            else
                splitted = regexp(ed,'\s\\\\\s','split');
                new      = char(splitted);
            end
            
            plotterT.lookUpMatrix{ind1,ind2} = new;
            
            % Adjust column width
            drawnow;
            if ishandle(hObject)
                table = get(hObject,'userdata'); % nb_uitable object stored here!
                update(table{1});
            end
            
            % Notify listeners
            notify(gui,'changedGraph');

    else
        nb_errorWindow('Error while edit the selected cell of the table') 
    end

end

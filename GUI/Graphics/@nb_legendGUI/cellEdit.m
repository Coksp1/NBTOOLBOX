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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;

    if isempty(event.Error)

        if event.Indices(2) == 2

            % Get the edited legend
            data = get(hObject,'data');
            row  = event.Indices(1);
            var  = data{row,1};
            ed   = data{row,2};
            
            % Check for multi-lined legend
            ind = strfind(ed,'\\');
            if isempty(ind)
                newLegend = ed;
            else
                splitted  = regexp(ed,'\s\\\\\s','split');
                newLegend = char(splitted);
            end
            
            % Update the legend
            ind = find(strcmp(var,plotterT.legendText),1);
            if isempty(ind)
                plotterT.legendText = [plotterT.legendText,{var,newLegend}];
            else
                plotterT.legendText{ind+1} = newLegend;
            end
            
            % Adjust column width
            drawnow;
            if ishandle(hObject)
                table = get(hObject,'userdata'); % nb_uitable object stored here!
                update(table{1});
            end

            % Notify listeners
            notify(gui,'changedGraph');

        end

    else
        nb_errorWindow('Error while edit the selected cell of the table') 
    end 

end

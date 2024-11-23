function cellEdit(gui,~,event)
% Syntax:
%
% cellEdit(gui,hObject,event)
%
% Description:
%
% Part of DAG. Edit table callback.

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(event.Error)

        ind1  = event.Indices(1);
        ind2  = event.Indices(2);
        ind3  = get(gui.list,'value');
        cellM = gui.tableData;
        
        % Assign changes
        ed          = event.EditData;
        prev        = event.PreviousData;
        tData       = get(gui.table,'data');
        tDataBackup = tData;
        
        tDataBackup{ind1,ind2,1} = prev;           
        tData{ind1,ind2,1}       = ed;
        
        if strcmpi(prev,'not editable')
            set(gui.table,'data',tDataBackup);
            %nb_errorWindow('The cell you try to edit is not editable')
            return
        end
        
        cellM(1:size(tData,1),:,ind3) = tData;
        set(gui.table,'data',tData);
        gui.tableData = cellM;
        
    else
        nb_errorWindow('Error while edit the selected cell of the table') 
    end

end

function cellEdit(gui,~,event)
% Callback function when editing the legends    

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj = gui.parent;
    if isempty(event.Error)

            ind1 = event.Indices(1);
            ind2 = event.Indices(2);
        
            % Assign changes
            ed  = event.NewData;
            if isnan(ed)
                data            = get(gui.table,'data');
                data(ind1,ind2) = event.PreviousData;
                set(gui.table,'data',data);
                nb_errorWindow('All coordinates must be numbers')
                return
            end
            if ind2 == 1 
                obj.xData(ind1) = ed;
            else
                obj.yData(ind1) = ed;
            end
            
            % Notify listeners
            update(obj);
            notify(obj,'annotationEdited')

    else
        nb_errorWindow('Error while edit the selected cell of the table') 
    end

end

function editableCallback(gui,~,~)
% Syntax:
%
% editableCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Called when the user choose to make the table editable.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    editMenu = findobj(gui.viewMenu,'Label','Editable');
    if gui.editMode == 0
        
        if gui.data.isUpdateable
            nb_infoWindow(['Be aware that the data is updatable. This means that even if the source data change, '...
                'the edited cell(s) will not be updated with the updated data from the source! It is still possible to '...
                'delete the editing. Please see Dataset\Method List'])  
        end
        
        % See the method set.editMode. This will make the table editable
        gui.editMode = 1;
        checked      = 'on';
        
    else
        % See the method set.editMode. This will make the table editable
        gui.editMode = 0;
        checked      = 'off';
    end

    set(editMenu,'checked',checked);
    
end

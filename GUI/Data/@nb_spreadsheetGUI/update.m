function update(gui,~,~)
% Syntax:
%
% update(gui,hObject,event)
%
% Description:
%
% Part of DAG. Update current dataset
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(gui.data)
        nb_errorWindow('No data loaded. Nothing to update.')
        return
    end

    nb_confirmWindow('Are you sure you want to update the data?',@notUpdateCurrent,{@updateCurrent,gui},[gui.parent.guiName ': Update dataset']);

    function updateCurrent(hObject,~,gui)

        % Close confirm window
        close(get(hObject,'parent'));
        
        if gui.data.isUpdateable()

            try
                gui.data = gui.data.update('off','on');
            catch Err
                message = ['The data couldn''t be updated.',nb_newLine(2), ...
                           'Either the link to the data source is broken, or you don''t have access to the',nb_newLine(1),...
                            'relevant databases.',nb_newLine(2),...
                            'MATLAB error: '];
                nb_errorWindow(char(message), Err)
                return
            end
            if ~isempty(gui.transData)
                gui.transData = gui.transData.update();
            end
            
            updateTable(gui);
            nb_infoWindow('The dataset is updated.',[gui.parent.guiName ': Update'])

            % Update the changed property
            gui.changed = 1;
            
            % notify that the data has been updated. See the constructor of 
            % the nb_spreadsheetAdvGUI class
            notify(gui,'updatedData')

        else
            nb_errorWindow('The dataset is not updateable. No link to the data source.')
        end

    end

    function notUpdateCurrent(hObject,~)

        % Close confirm window
        close(get(hObject,'parent'));

    end

end

function breakLinkCallback(gui,~,~)
% Syntax:
%
% breakLinkCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(gui.data) || ~gui.data.isUpdateable
        nb_errorWindow('The data is not updateable. No link to break.')
        return
    end

    nb_confirmWindow('Are you sure you want to break the link to the data source?',@notBreakCurrent,{@breakCurrent,gui},[gui.parent.guiName ': Break link']);

    function breakCurrent(hObject,~,gui)

        % Close confirm window
        close(get(hObject,'parent'));
        
        % Break link
        gui.data = breakLink(gui.data);
        
        % Update the changed property
        gui.changed = 1;

        % notify that the data has been updated. See the constructor of 
        % the nb_spreadsheetAdvGUI class
        notify(gui,'updatedData')

    end

    function notBreakCurrent(hObject,~)

        % Close confirm window
        close(get(hObject,'parent'));

    end

end

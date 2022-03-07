function deleteCallback(gui,~,~)
% Syntax:
%
% deleteCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Delete the selected variables of the list, and update the
% list and the table of its parent
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get selected dataset
    index        = get(gui.listbox,'Value');
    string       = get(gui.listbox,'String');
    varsToDelete = string(index);
    if isempty(varsToDelete)
        return
    end

    % Get the nb_ts or nb_cs object with the data
    switch lower(gui.type)
        case 'variables'
            
            gui.data = gui.data.deleteVariables(varsToDelete);

            % Get the varibales left
            varsLeft = gui.data.variables;

            if isempty(varsLeft)

                % Close window
                close(gui.figureHandle);

                % Give a message explaining what's going on
                nb_errorWindow('You have deleted all variables of the dataset.')

            else

                % Update the list box
                set(gui.listbox,'Value',1,'String',varsLeft,'max',gui.data.numberOfVariables);

            end
        
        case 'types'
            
            gui.data = gui.data.deleteTypes(varsToDelete);
            
            %Get the types left
            typesLeft = gui.data.types;
            
            if isempty(typesLeft)
                
                %Close Window
                close(gui.figureHandle);
                
                %Give a message explaining what's going on
                nb_errorWindow('You have deleted all types of the dataset.')
            else
                
                %Update the list box
                set(gui.listbox,'Value',1,'String',typesLeft,'max',gui.data.numberOfTypes);
            
            end
            
    end
    
    % Notify listeners
    notify(gui,'methodFinished');

end  

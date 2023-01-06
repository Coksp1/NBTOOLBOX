function addCallback(gui,hObject,~)
% Syntax:
%
% addCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. The function called when the OK button is pushed in the GUI
% window.
% 
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the added string
    location = nb_getUIControlValue(gui.location,'numeric');
  
    if isnan(location)
        nb_errorWindow('The location input must be an integer.')
        return
    elseif ~nb_isScalarInteger(location)
        nb_errorWindow('The location input must be an integer.')
        return
    elseif location < 1
        nb_errorWindow('The location input must be an integer greater than 0.')
        return
    end
    
    if strcmpi(gui.type,'row')
        m = size(gui.data.data,1); 
    else
        m = size(gui.data.data,2);
    end
    if location > m
        nb_errorWindow(['The location input cannot be greater than ' int2str(m) '.'])
        return
    end
    
    % Evaluate the expression
    try
        if strcmpi(gui.type,'row')
            gui.data = addRow(gui.data,location);
        else
            gui.data = addColumn(gui.data,location);
        end
    catch Err
        nb_errorWindow(['Could not add a ' gui.type ' to the object.'], Err)
        return
    end
    
    % Close window
    close(get(hObject,'parent'));
    
    % Notify listeners
    notify(gui,'methodFinished');

end

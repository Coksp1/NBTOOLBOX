function calculateCallback(gui,~,~)
% Syntax:
%
% calculateCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. The function called when the OK button is pushed in the GUI
% window.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the selected options
    backwardT = get(gui.edit1,'string');
    forwardT  = get(gui.edit2,'string');
    postfix   = get(gui.edit3,'string');
    string    = get(gui.list1,'string');
    index     = get(gui.list1,'value');
    vars      = string(index);
    
    % Check for errors
    backward = str2double(backwardT);
    if isnan(backward)
        nb_errorWindow(['The number of periods backward must be given as a number. Not ''' backwardT '''.'])
        return
    end
    
    forward = str2double(forwardT);
    if isnan(forward)
        nb_errorWindow(['The number of periods forward must be given as a number. Not ''' forwardT '''.'])
        return
    end
    
    % Evaluate the expression
    switch lower(gui.type)
        case {'mstd', 'mavg'}
            inputs = {backward,forward};
        otherwise
            inputs = {};
    end
    
    if get(gui.rball,'value') && isempty(postfix)
        
        func = str2func(lower(gui.type));
        try
            gui.data = func(gui.data,inputs{:});
        catch Err
            nb_errorWindow('Could not evaluate method. Please see error below.',Err)
            return
        end
        
    else
    
        if isempty(postfix)
            nb_errorWindow('The postfix cannot be empty.')
            return
        end
        
        message = nb_checkPostFix(postfix);
        if ~isempty(message)
            nb_errorWindow(message);
            return
        end

        try
            gui.data = extMethod(gui.data,lower(gui.type),vars,postfix,inputs{:});
        catch Err
            varsT = strcat(vars,postfix);
            ind   = ismember(varsT,gui.data.variables);
            if any(ind)
                nb_errorWindow(['The postfix resulted in duplication of the variables; ' toString(vars(ind))]) 
            else
                nb_errorWindow('Could not evaluate method. Please see error below.',Err)
            end
            return
        end
        
    end
    
    % Notify listeners
    notify(gui,'methodFinished');
    
    % Close window
    close(gui.figureHandle);

end

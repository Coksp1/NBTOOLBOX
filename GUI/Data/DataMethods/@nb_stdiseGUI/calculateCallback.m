function calculateCallback(gui,~,~)
% Syntax:
%
% calculateCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the selected options
    flag      = ~get(gui.rb1,'value');
    postfix   = get(gui.edit1,'string');
    string    = get(gui.list1,'string');
    index     = get(gui.list1,'value');
    vars      = string(index);
    
    if get(gui.rball,'value') && isempty(postfix)
        
        gui.data = stdise(gui.data,flag);
        
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

        funcName = 'stdise';
        inputs = {flag};

        try
            gui.data = extMethod(gui.data,funcName,vars,postfix,inputs{:});
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

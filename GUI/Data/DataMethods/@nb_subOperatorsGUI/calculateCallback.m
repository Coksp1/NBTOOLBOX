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

    % Get the periods selected
    frequency  = nb_getUIControlValue(gui.comp.frequency,'numeric');
    postfix    = nb_getUIControlValue(gui.comp.postFix);
    vars       = nb_getUIControlValue(gui.comp.variableList);
    
    % Check for errors
    if isempty(frequency)
        nb_errorWindow(['The frequency must be given as a number. Not ''' frequency '''.'])
        return
    elseif isnan(frequency)
        nb_errorWindow(['The frequency must be given as a number. Not ''' frequency '''.'])
        return
    end
    
    % Evaluate the expression
    inputs = {frequency};
    
    if get(gui.comp.radioButton,'value') && isempty(postfix)  
        
        func = str2func(gui.type);
        try
            gui.data = func(gui.data,inputs{:});
        catch Err
            nb_errorWindow('Could not evaluate method. Please see error below.',Err)
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
            gui.data = extMethod(gui.data,gui.type, vars, postfix, inputs{:}); 
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

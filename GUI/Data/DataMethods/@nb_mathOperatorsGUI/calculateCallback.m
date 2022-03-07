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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the periods selected
    postfix = get(gui.edit1,'string');
    string  = get(gui.list1,'string');
    index   = get(gui.list1,'value');
    vars    = string(index);
    
    % Evaluate the expression
    if get(gui.rball,'value') && isempty(postfix)
        
        func = str2func(lower(gui.type));
        switch lower(gui.type) 
            case {'mtimes','mrdivide','plus','minus','mpower'}

                % Get the value selected
                value = get(gui.edit2,'string');
                value = str2double(value);
                if isnan(value) || isempty(value)
                    nb_errorWindow('The value selected must be a number')
                    return
                end
                temp = func(gui.data,value);

            otherwise
                temp = func(gui.data);
        end
        gui.data = temp;
        
    else % New variables are added!
        
        % Check for errors
        if isempty(postfix)
            nb_errorWindow('The postfix cannot be empty.')
            return
        end
    
        message = nb_checkPostFix(postfix);
        if ~isempty(message)
            nb_errorWindow(message);
            return
        end
        
        switch lower(gui.type) 
            case {'mtimes','mrdivide','plus','minus','mpower'}
                value = get(gui.edit2,'string');
                value = str2double(value);
                if isnan(value) || isempty(value)
                    nb_errorWindow('The value selected must be a number')
                    return
                end
                inputs = {value};
            otherwise
                inputs = {};
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

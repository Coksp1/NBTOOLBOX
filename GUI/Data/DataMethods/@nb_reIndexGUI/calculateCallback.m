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

    % Get the selected options
    date      = get(gui.edit1,'string');
    postfix   = get(gui.edit2,'string');
    baseValue = get(gui.edit3,'string');
    string    = get(gui.list1,'string');
    index     = get(gui.list1,'value');
    vars      = string(index);
    
    if isempty(postfix)
        nb_errorWindow('The postfix cannot be empty.')
        return
    end
    
    message = nb_checkPostFix(postfix);
    if ~isempty(message)
        nb_errorWindow(message);
        return
    end
    
    baseValue = str2double(baseValue);
    if isnan(baseValue)
        nb_errorWindow('The base value must be given as a number')
        return
    end
    
    if isa(gui.data,'nb_data')
        
        % Check for errors
        newObs = round(str2double(date));
        if isnan(newObs)
            nb_errorWindow('The provided date is on a wrong date format.')
            return
        end
        
        % Evaluate the expression
        inputs = {newObs,baseValue};
        try  
            gui.data = extMethod(gui.data,'reIndex',vars,postfix,inputs{:});
        catch Err

            if strcmpi(Err.identifier,'nb_data:reIndex:outsideBounds')
                nb_errorWindow('The date provided is outside the time span of the object.')
                return
            else
                nb_errorWindow('Error while rebasing the object.')
                return
            end

        end
        
    else
    
        % Check for errors
        [newDate,message] = nb_reIndexGUI.interpretDate(gui.data,date);
        if ~isempty(message)
            nb_errorWindow(message)
            return
        end

        if newDate.frequency > gui.data.startDate.frequency
            nb_errorWindow('It is not possible to rebase to a date with higher frequency than the frequency of the object.')
            return
        end

        % Evaluate the expression
        inputs = {newDate,baseValue};
        try  
            gui.data = extMethod(gui.data,'reIndex',vars,postfix,inputs{:});
        catch Err

            if strcmpi(Err.identifier,'nb_ts:reIndex:outsideBounds')
                nb_errorWindow('The date provided is outside the time span of the object.')
                return
            else
                nb_errorWindow('Error while rebasing the object.',Err)
                return
            end

        end

    end
    
    % Notify listeners
    notify(gui,'methodFinished');
    
    % Close window
    close(gui.figureHandle);

end

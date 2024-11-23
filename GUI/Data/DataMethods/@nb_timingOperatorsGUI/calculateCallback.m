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
    numPeriodsT = get(gui.edit1,'string');
    postfix     = get(gui.edit2,'string');
    string      = get(gui.list1,'string');
    index       = get(gui.list1,'value');
    vars        = string(index);
    
    % Check for errors
    numPeriods = str2double(numPeriodsT);
    if isnan(numPeriods)
        nb_errorWindow(['The number of periods must be given as a number. Not ''' numPeriodsT '''.'])
        return
    end
    
    if isempty(postfix)
        nb_errorWindow('The postfix cannot be empty.')
        return
    end
    
    % Evaluate the expression
    switch lower(gui.type)
        case {'lead', 'lag'}
            inputs = {numPeriods};
        otherwise
            inputs = {};
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
    
    % Notify listeners
    notify(gui,'methodFinished');
    
    % Close window
    close(gui.figureHandle);

end

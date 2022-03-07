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
    if strcmp(gui.type,'sgrowth')
        horizon = nb_getUIControlValue(gui.comp.horizon,'numeric');
    else
        numPeriods = nb_getUIControlValue(gui.comp.numberOfPeriods,'numeric');
        if isnan(numPeriods)
            nb_errorWindow(['The number of periods must be given as a number. Not ''' numPeriodsT '''.'])
            return
        end
    end
    postfix = nb_getUIControlValue(gui.comp.postFix);
    vars    = nb_getUIControlValue(gui.comp.variableList);
    
    % Evaluate the expression    
    switch lower(gui.type)
        case {'growth', 'egrowth', 'pcn', 'epcn'}
            inputs = {numPeriods};
        case {'sgrowth'}
            inputs = {horizon};
        otherwise
            inputs = {};
    end
    
    if get(gui.comp.radioButton,'value') && isempty(postfix)
        
        func = str2func(lower(gui.type));
        try
            gui.data = func(gui.data,inputs{:});
        catch Err
            nb_errorWindow('Could not evaluate method. Please see error below.',Err)
        end
        
        % Check the multiply option
        if isa(gui.data,'nb_ts')
            if gui.data.frequency <= 12
                num      = nb_getUIControlValue(gui.comp.multi,'numeric');
                gui.data = mtimes(gui.data,num);
            end
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
            gui.data = extMethod(gui.data, lower(gui.type), vars, postfix, inputs{:}); 
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

        % Check the multiply option
        if isa(gui.data,'nb_ts')
            if gui.data.frequency <= 12
                num      = nb_getUIControlValue(gui.comp.multi,'numeric');
                gui.data = extMethod(gui.data, 'mtimes', strcat(vars, postfix), '', num);
            end
        end
        
    end
    
    % Notify listeners
    notify(gui,'methodFinished');
    
    % Close window
    close(gui.figureHandle);

end

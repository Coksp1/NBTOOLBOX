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
    inputs = {};
    dim    = nb_getUIControlValue(gui.comp.dim,'userdata');
    if ~isa(gui.data,'nb_cs') && dim == 1
        
        start                    = nb_getUIControlValue(gui.comp.start);
        [start,message,startObj] = nb_interpretDateObsTypeInputDataGUI(gui.data,start);
        if ~isempty(message)
            nb_errorWindow(message);
            return
        end
        
        finish                     = nb_getUIControlValue(gui.comp.finish);
        [finish,message,finishObj] = nb_interpretDateObsTypeInputDataGUI(gui.data,finish);
        if ~isempty(message)
            nb_errorWindow(message);
            return
        end
        
        if ~isempty(start)
            if gui.data.startDate > startObj
                nb_errorWindow(['The start observation (' toString(startObj) ') cannot be before the start observation of the data.'])
                return
            end
            if ~isempty(finishObj)
                if finishObj < startObj
                    nb_errorWindow(['The start observation (' toString(startObj) ') cannot be after the end observation (' toString(finishObj) ') of the data.'])
                    return
                end
            end
        else
            if ~isempty(finish)
                if gui.data.startDate > finishObj
                    nb_errorWindow(['The end observation (' toString(finishObj) ') cannot be before the start observation of the data.'])
                    return
                end
            end
        end
        if ~isempty(finish)
            if gui.data.endDate < finishObj
                nb_errorWindow(['The end observation (' toString(finishObj) ') cannot be after the end observation of the data.'])
                return
            end
        end
        
        inputs = {'<start>',start,'<end>',finish};
        
    end
    
    % Handle nan?
    extraInputs = {};
    if ~get(gui.comp.handleNaN,'value')
        extraInputs = {'notHandleNaN'};
    end
    
    % Check for errors
    postfix = nb_getUIControlValue(gui.comp.postfix);
    if nb_getUIControlValue(gui.comp.all) && isempty(postfix) && dim == 1
        
        inputs = {class(gui.data),dim};
        if strcmpi(gui.type,'std')
            inputs = [{0},inputs]; % flag input
        end
        inputs = [inputs,extraInputs];
        func   = str2func(lower(gui.type));
        try
            gui.data = func(gui.data,inputs{:});
        catch Err
            nb_errorWindow('Could not evaluate method. Please see error below.',Err)
            return
        end
        
    elseif dim == 3
        
        if nb_getUIControlValue(gui.comp.all)
            inputs = {class(gui.data),dim};
        else
            inputs = {[class(gui.data) '_scalar'],dim};
        end
        if strcmpi(gui.type,'std')
            inputs = [{0},inputs]; % flag input
        end
        inputs = [inputs,extraInputs];
        func   = str2func(lower(gui.type));
        try
            gui.data = func(gui.data,inputs{:});
        catch Err
            nb_errorWindow('Could not evaluate method. Please see error below.',Err)
            return
        end
        
    elseif dim == 2 && nb_getUIControlValue(gui.comp.all)
        
        inputs = {class(gui.data),dim};
        if strcmpi(gui.type,'std')
            inputs = [{0},inputs]; % flag input
        end
        inputs = [inputs,extraInputs];
        func   = str2func(lower(gui.type));
        try
            gui.data = func(gui.data,inputs{:});
        catch Err
            nb_errorWindow('Could not evaluate method. Please see error below.',Err)
            return
        end
        
    else
    
        if dim == 1
            
            if isempty(postfix)
                nb_errorWindow('The postfix cannot be empty if the all option is not ticked.')
                return
            end

            message = nb_checkPostFix(postfix);
            if ~isempty(message)
                nb_errorWindow(message);
                return
            end
            
        else
            postfix = '_';
        end
        
        className = class(gui.data);
        switch dim
            case 1
                outputType = className;
            case 2
                outputType = [className '_scalar'];
            case 3
                outputType = [className '_scalar'];
        end
                
        
        vars   = nb_getUIControlValue(gui.comp.variables);
        inputs = [{outputType,dim}, inputs];
        if strcmpi(gui.type,'std')
            inputs = [{0},inputs]; % flag input
        end
        inputs = [inputs,extraInputs];
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
    close(gui.comp.figureHandle);

end

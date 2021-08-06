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

    % Get the value selected
    value = get(gui.edit1,'string');
    if isempty(value) 
        value = 1;
    else
        value = str2double(value);
        if isnan(value)
            nb_errorWindow('The closest to option must be a number')
            return
        end
    end
    
    % Start obs
    sObs = get(gui.edit2,'string');
    if ~isempty(sObs)
        [~,message,sObs] = nb_interpretDateObsTypeInputDataGUI(gui.data,sObs);
        if ~isempty(message)
            nb_errorWindow(message);
            return
        end
    end

    % End obs
    eObs = get(gui.edit3,'string');
    if ~isempty(eObs)
        [~,message,eObs] = nb_interpretDateObsTypeInputDataGUI(gui.data,eObs);
        if ~isempty(message)
            nb_errorWindow(message);
            return
        end
    end
       
    % Get the pages selected
    pages = get(gui.edit4,'string');
    if ~isempty(pages) 
        pages = nb_str2double(pages);
        if isnan(pages)
            nb_errorWindow('The pages option must be a number')
            return
        end
    end
    
    % Selected variables
    string = get(gui.list1,'string');
    index  = get(gui.list1,'value');
    vars   = string(index);
    if get(gui.rball,'value')
        vars = {};
    end

    % Evaluate the expression  
    if isa(gui.data,'nb_cs')
        gui.data = round(gui.data,value,{},vars,pages);
    else
        gui.data = round(gui.data,value,sObs,eObs,vars,pages);
    end

    % Notify listeners
    notify(gui,'methodFinished');
    
    % Close window
    close(gui.figureHandle);

end

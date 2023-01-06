function windowCallback(gui,hObject,~)
% Syntax:
%
% windowCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. The function called when the OK button is pushed in the GUI
% window.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the new start date
    list     = get(gui.popupmenu1,'string');
    index    = get(gui.popupmenu1,'value');
    sObs     = list{index};
    
    % Get the new end date
    list     = get(gui.popupmenu2,'string');
    index    = get(gui.popupmenu2,'value');
    eObs     = list{index};

    % Start obs
    if ~isempty(sObs)
        [sObs,message,sObsObj] = nb_interpretDateObsTypeInputDataGUI(gui.data,sObs);
        if ~isempty(message)
            nb_errorWindow(message);
            return
        end
    end

    % End obs
    if ~isempty(eObs)
        [eObs,message,eObsObj] = nb_interpretDateObsTypeInputDataGUI(gui.data,eObs);
        if ~isempty(message)
            nb_errorWindow(message);
            return
        end
    end
    
    % Check the selected dates/obs
    if ~isempty(sObs) && ~isempty(eObs)
        if sObsObj > eObsObj
            nb_errorWindow(['The provided start obs (' int2str(newStart) ') cannot be after the selected end date (' int2str(newEnd) ').'])
        end
    end
    
    % Evaluate the expression
    try
        gui.data = gui.data.window(sObs,eObs);
    catch Err
        nb_errorWindow(Err.message)
    end
        
    % Notify listeners
    notify(gui,'methodFinished');
    
    % Close window
    close(get(hObject,'parent'));

end  

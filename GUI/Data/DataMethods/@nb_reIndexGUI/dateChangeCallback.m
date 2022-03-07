function dateChangeCallback(gui,hObject,~)
% Syntax:
%
% dateChangeCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    string = get(hObject,'string');
    if isa(gui.data,'nb_ts')
            
        [newDate,message] = nb_reIndexGUI.interpretDate(gui.data,string);
        if ~isempty(message)
            nb_errorWindow(message)
            return
        end
        
        if newDate.frequency > gui.data.startDate.frequency
            nb_errorWindow('It is not possible to rebase to a date with higher frequency than the frequency of the object.')
            return
        end

        % Update the postfix if it has not been edited
        postfix = get(gui.edit2,'string');
        if strcmpi(postfix,['_' toString(gui.oldDate)])
            set(gui.edit2,'string',['_' toString(newDate)]);
        end

        % Update property
        gui.oldDate = newDate;
        
    else
        
        newObs = round(str2double(string));
        if isnan(newObs)
            nb_errorWindow('The provided obs must be a number.')
            return
        end

        % Update the postfix if it has not been edited
        postfix = get(gui.edit2,'string');
        if strcmpi(postfix,['_' int2str(gui.oldObs)])
            set(gui.edit2,'string',['_' int2str(newObs)]);
        end

        % Update property
        gui.oldObs = newObs;
        
    end
    
end

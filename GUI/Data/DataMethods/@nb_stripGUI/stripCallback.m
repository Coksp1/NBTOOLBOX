function stripCallback(gui,hObject,~)
% Syntax:
%
% stripCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the added string
    string = get(gui.list1,'string');
    index  = get(gui.list1,'value');
    vars   = string(index);
    
    % Evaluate the expression
    switch lower(gui.type)
        
        case 'strip'  
            
            % Start obs
            sObs = get(gui.editbox1,'string');
            if ~isempty(sObs)
                [~,message,sObs] = nb_interpretDateObsTypeInputDataGUI(gui.data,sObs);
                if ~isempty(message)
                    nb_errorWindow(message);
                    return
                end
            end

            % End obs
            eObs = get(gui.editbox2,'string');
            if ~isempty(eObs)
                [~,message,eObs] = nb_interpretDateObsTypeInputDataGUI(gui.data,eObs);
                if ~isempty(message)
                    nb_errorWindow(message);
                    return
                end
            end

            % Check the selected dates/obs
            if sObs > eObs
                nb_errorWindow(['The provided start obs (' int2str(newStart) ') cannot be after the selected end date (' int2str(newEnd) ').'])
            end

            if isa(gui.data,'nb_ts')

                if sObs < gui.data.startDate || sObs > gui.data.endDate
                    nb_errorWindow('The selected start date must be inside the window of the dataset.')
                    return
                end

                if eObs < gui.data.startDate || eObs > gui.data.endDate
                    nb_errorWindow('The selected end date must be inside the window of the dataset.')
                    return
                end

            else

                if sObs < gui.data.startObs || sObs > gui.data.endObs
                    nb_errorWindow('The selected start obs must be inside the window of the data set.')
                    return
                end

                if eObs < gui.data.startObs || eObs > gui.data.endObs
                    nb_errorWindow('The selected end obs must be inside the window of the data set.')
                    return
                end

            end

            % Call the strip function
            gui.data = strip(gui.data,sObs,eObs,vars);
            
        otherwise 
            
            string = get(gui.editbox1,'string');
            num    = round(str2double(string));
            if isnan(num)
                nb_errorWindow('The periods option must be a number greater than 0.')
                return
            elseif num <= 0
                nb_errorWindow('The periods option must be a number greater than 0.')
                return
            end
            
            gui.data = stripButLast(gui.data,num,vars);
            
    end
    
    % Close window
    close(get(get(hObject,'parent'),'parent'));
    
    % Notify listeners
    notify(gui,'methodFinished');

end

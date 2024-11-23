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

    if strcmp(get(gui.timeDummyPanel,'visible'),'on')
       
        % Get selected options
        dummyName = get(gui.edit1,'string');
        [dummyName,message] = nb_checkSaveName(dummyName,1);
        if ~isempty(message)
            nb_errorWindow(['Invalid dummy name, Error:  ' message]);
            return
        end
        dummyDate = get(gui.edit2,'string');
        string    = get(gui.pop2,'string');
        index     = get(gui.pop2,'value');
        operation = string{index};
        
        % Check selected options
        if isa(gui.data,'nb_ts')
            
            try
                dummyDate = nb_date.toDate(dummyDate,gui.data.frequency);
            catch %#ok<CTCH>
                nb_errorWindow('The date provided is of wrong frequency or on a wrong date format.')
                return
            end

            if dummyDate > gui.data.endDate || dummyDate < gui.data.startDate
               nb_errorWindow('Dummy date cannot be outside the data range'); 
               return
            end
            
        else % nb_data
            
            dummyObs = round(str2double(dummyDate));
            if isnan(dummyObs)
                nb_errorWindow('The obs provided is not a number!')
                return
            end
            
        end
        
        ind = strcmp(dummyName,gui.data.variables);
        if any(ind)
            nb_errorWindow('The name of the dummy variable is already in use.')
            return
        end
        
        % Calculate
        if isa(gui.data,'nb_ts')
            gui.data = createTimeDummy(gui.data,dummyName,dummyDate,operation);
        else
            gui.data = createObsDummy(gui.data,dummyName,dummyObs,operation);
        end
        
    elseif strcmp(get(gui.varDummyPanel,'visible'),'on')
        
        % Get selected options
        dummyName = get(gui.edit3,'string');
        tableData = get(gui.table,'data');
        
        % Check selected options
        ind = strcmp(dummyName,gui.data.variables);
        if any(ind)
            nb_errorWindow('The name of the dummy variable is already in use.')
            return
        end
        
        numRestrictions = size(tableData,1);
        inputs          = cell(1,numRestrictions*4);
        for ii = 1:numRestrictions
            
            inputs{ii*4 - 3} = tableData{ii,1};
            inputs{ii*4 - 2} = tableData{ii,2};
            inputs{ii*4}     = tableData{ii,4};
            condition        = tableData{ii,3};
            
            % Here the condition input could either be a variable
            % or a numerical value.
            condT = str2double(condition);
            if isnan(condT)
            
                ind = strcmp(condition,gui.data.variables);
                if ~any(ind)
                    nb_errorWindow(['The condition in row ' int2str(ii) ' is invalid. '...
                        'A numerical value or the name of a variable of the dataset is the only valid inputs.'])
                    return
                end
                
            else
                condition = condT;
            end
            inputs{ii*4 - 1} = condition;
            
        end
        
        % Calculate
        gui.data = createVarDummy(gui.data,dummyName,inputs{:});
        
    elseif strcmp(get(gui.seasonalDummyPanel,'visible'),'on')
        
        index  = get(gui.pop3,'value');
        string = get(gui.pop3,'string');
        type   = string{index};
        
        % Calculate
        try
            gui.data = createSeasonalDummy(gui.data,type);
        catch Err
           nb_errorWindow('Couldn''t create seasonal dummies. ', Err);
           return
        end
        
    end
    
    % Notify listeners
    notify(gui,'methodFinished');
    
    % Close window
    close(gui.figureHandle);
    
end

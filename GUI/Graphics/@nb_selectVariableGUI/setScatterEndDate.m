function setScatterEndDate(gui,hObject,~)
% Syntax:
%
% setScatterEndDate(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback function for changing the scatter group end date
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the scatter groupes
    plotterT  = gui.plotter;
    
    % Get the interpreted input
    string                 = get(hObject,'string');
    [newValue,message,obj] = nb_interpretDateObsTypeInputGUI(plotterT,string);
    string2                = get(gui.editbox2,'string');
    [~,~,objS]             = nb_interpretDateObsTypeInputGUI(plotterT,string2);
    
    if ~isempty(message)
        nb_errorWindow(message);
        return
    end
    
    if isa(plotterT,'nb_graph_ts')
        
        if strcmpi(obj.scatterSide,'left')
            plotterT.setSpecial('returnLocal',1);
            scaGroups = plotterT.scatterDates;
            plotterT.setSpecial('returnLocal',0);
            property  = 'scatterDates';
        else
            plotterT.setSpecial('returnLocal',1);
            scaGroups = plotterT.scatterDatesRight;
            plotterT.setSpecial('returnLocal',0);
            property  = 'scatterDatesRight';
        end
        periods = obj - plotterT.DB.startDate;
        if periods < 0 || periods > plotterT.DB.numberOfObservations - 1
            nb_errorWindow(['The provided end date of the scatter group is outside the date interval of the data. '...
                            '(' plotterT.DB.startDate.toString() ':' plotterT.DB.endDate.toString() ')'])
            return
        end

        if obj < objS
            nb_errorWindow(['The provided end date (' obj.toString ') of the scatter group cannot be before the start date '...
                            'of the scatter group (' objS.toString() ')'])
            return
        end
        
    else % nb_graph_data
        
        if strcmpi(gui.scatterSide,'left')
            plotterT.setSpecial('returnLocal',1);
            scaGroups = plotterT.scatterObs;
            plotterT.setSpecial('returnLocal',0);
            property  = 'scatterObs';
        else
            plotterT.setSpecial('returnLocal',1);
            scaGroups = plotterT.scatterObsRight;
            plotterT.setSpecial('returnLocal',0);
            property  = 'scatterObsRight';
        end
        periods   = obj - plotterT.DB.startObs;
        if periods < 0 || periods > plotterT.DB.numberOfObservations - 1
            nb_errorWindow(['The provided end obs of the scatter group is outside the observation interval of the data. '...
                            '(' int2str(plotterT.DB.startObs) ':' int2str(plotterT.DB.endObs) ')'])
            return
        end

        if obj < objS
            nb_errorWindow(['The provided end obs (' int2str(obj) ') of the scatter group cannot be before the start obs '...
                            'of the scatter group (' int2str(objS) ')'])
            return
        end
        
    end
    
    % Get the scatter group selected
    strings = get(gui.popupmenu1,'string');
    index   = get(gui.popupmenu1,'value');
    group   = strings{index};

    % Update the scatter group
    ind                = find(strcmp(group,scaGroups),1);
    obs                = scaGroups(ind + 1);
    obs                = obs{1};
    obs{2}             = newValue;
    scaGroups(ind + 1) = {obs};

    % Update the graph object
    plotterT.set(property, scaGroups);

    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');

end

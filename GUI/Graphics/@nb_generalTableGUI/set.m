function set(gui,hObject,~,type)
% Syntax:
%
% set(gui,hObject,event,type)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    switch lower(type)
          
        case 'decimals'
            
            string = get(hObject,'string');
            value  = get(hObject,'value');
            new    = string{value};
            if value < 11
                new = str2double(new);
            end
            if isnan(new)
                new = [];
            end
            plotterT.decimals = new;
            
        case 'endtable'
            
            string = get(hObject,'string');
            [newValue,message,obj] = nb_interpretDateObsTypeInputGUI(plotterT,string);

            if ~isempty(message)
                nb_errorWindow(message);
                return
            end

            if isa(plotterT,'nb_table_ts')

                if obj < plotterT.DB.startDate
                    nb_errorWindow(['The table end date ''' obj.toString() ''' is before the start date of the data (' plotterT.DB.startDate.toString() '), which is not possible.']);
                    return
                elseif obj < plotterT.startTable
                    nb_errorWindow(['The table end date ''' obj.toString() ''' is before the start date of the table (' plotterT.startTable.toString() '), which is not possible.']);
                    return
                end

            else % nb_graph_data

                if obj < plotterT.DB.startObs
                    nb_errorWindow(['The table end obs ''' string ''' is before the start obs of the data (' int2str(plotterT.DB.startObs) '), which is not possible.']);
                    return
                elseif obj < plotterT.startTable
                    nb_errorWindow(['The table end obs ''' string ''' is before the start obs of the table (' int2str(plotterT.startTable) '), which is not possible.']);
                    return
                end

            end

            % Plot
            plotterT.set('endTable',newValue);

        case 'fontscale'
            
            string   = get(hObject,'string');
            value    = str2double(string);
            if isnan(value)
                nb_errorWindow(['The font scale must be set to a number greater then 0. Is ' string '.'])
                return
            elseif value <= 0
                nb_errorWindow(['The font scale must be set to a number greater then 0. Is ' string '.'])
                return
            end
            plotterT.fontScale = value;   
            
        case 'fontsize'
            
            string = get(hObject,'string');
            value  = str2double(string);
            if isnan(value)
                nb_errorWindow(['The font size must be set to a number greater then 0. Is ' string '.'])
                return
            elseif value <= 0
                nb_errorWindow(['The font size must be set to a number greater then 0. Is ' string '.'])
                return
            end
            plotterT.fontSize = value;     
            
        case 'language'
            
            plotterT.language = nb_getUIControlValue(hObject);
            
        case 'mode'
            
            plotterT.table.mode = nb_getUIControlValue(hObject);
            
        case 'spacing'
            
            string = get(hObject,'string');
            value  = str2double(string);
            if isnan(value)
                nb_errorWindow(['Spacing must be set to a integer greater then 0. Is ' string '.'])
                return
            elseif value <= 0
                nb_errorWindow(['Spacing must be set to a integer greater then 0. Is ' string '.'])
                return
            elseif ~nb_iswholenumber(value)
                nb_errorWindow(['Spacing must be set to an integer greater then 0. Is ' string '.'])
                return
            end
            plotterT.spacing = value; 
            
        case 'starttable'
               
            string = get(hObject,'string');
            [newValue,message,obj] = nb_interpretDateObsTypeInputGUI(plotterT,string);

            if ~isempty(message)
                nb_errorWindow(message);
                return
            end

            if isa(plotterT,'nb_table_ts')

                if obj > plotterT.DB.endDate
                    nb_errorWindow(['The table start date ''' obj.toString() ''' is after the end date of the data (' plotterT.DB.endDate.toString() '), which is not possible.']);
                    return
                elseif obj > plotterT.endTable
                    nb_errorWindow(['The table start date ''' obj.toString() ''' is after the end date of the table (' plotterT.endTable.toString() '), which is not possible.']);
                    return
                end

            else % nb_graph_data

                if obj > plotterT.DB.endObs
                    nb_errorWindow(['The table start obs ' string ' is after the end obs of the data (' int2str(plotterT.DB.endObs) '), which is not possible.']);
                    return
                elseif obj > plotterT.endTable
                    nb_errorWindow(['The table start obs ' string ' is after the end obs of the table (' int2str(plotterT.endTable) '), which is not possible.']);
                    return
                end

            end

            % Plot
            plotterT.set('startTable',newValue);
             
    end
    
    % Notify listeners
    notify(gui,'changedGraph');
     
end


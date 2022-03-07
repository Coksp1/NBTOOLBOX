function paste(gui,~,~,type)
% Syntax:
%
% paste(gui,hObject,event,type)
%
% Description:
%
% Part of DAG. Paste data from clipboard (when type is either ',' or '.')  
% and transform it into a graph or paste the local object into a graph.
% ('local'). The objects which could be pasted are nb_ts, nb_cs, 
% nb_graph_ts, nb_graph_cs and nb_graph_adv objects.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch lower(type)
        
        case 'local'
            
            object = gui.parent.copiedObject;
            if isempty(object)
                nb_errorWindow('Cannot paste a empty object')
                return
            end
            
            if isa(object,'nb_graph_ts')
                
                object = copy(object);
                
                % Create a graph GUI (time-series)
                if strcmpi(gui.type,'advanced')
                    applyDefault(gui.parent,object,gui.template);
                    object = nb_graph_adv(object);
                    nb_graph_tsGUI(gui.parent,gui.type,object);
                else
                    nb_graph_tsGUI(gui.parent,gui.type,object);
                end
                
            elseif isa(object,'nb_table_ts')
                
                object = copy(object);
                
                % Create a graph GUI (time-series)
                if strcmpi(gui.type,'advanced')
                    object = nb_graph_adv(object);
                    nb_table_tsGUI(gui.parent,gui.type,object);
                else
                    nb_table_tsGUI(gui.parent,gui.type,object);
                end    
                
            elseif isa(object,'nb_graph_cs')
                
                object = copy(object);
                
                % Create a graph GUI (cross-sectional)
                if strcmpi(gui.type,'advanced')
                    applyDefault(gui.parent,object,gui.template);
                    object = nb_graph_adv(object);
                    nb_graph_csGUI(gui.parent,gui.type,object);
                else
                    nb_graph_csGUI(gui.parent,gui.type,object);
                end
                
            elseif isa(object,'nb_table_cs')
                
                object = copy(object);
                
                % Create a graph GUI (cross-sectional)
                if strcmpi(gui.type,'advanced')
                    object = nb_graph_adv(object);
                    nb_table_csGUI(gui.parent,gui.type,object);
                else
                    nb_table_csGUI(gui.parent,gui.type,object);
                end    
                
            elseif isa(object,'nb_graph_data')
                
                object = copy(object);
                
                % Create a graph GUI (cross-sectional)
                if strcmpi(gui.type,'advanced')
                    applyDefault(gui.parent,object,gui.template);
                    object = nb_graph_adv(object);
                    nb_graph_dataGUI(gui.parent,gui.type,object);
                else
                    nb_graph_dataGUI(gui.parent,gui.type,object);
                end    
                
            elseif isa(object,'nb_table_data')
                
                object = copy(object);
                
                % Create a graph GUI (cross-sectional)
                if strcmpi(gui.type,'advanced')
                    object = nb_graph_adv(object);
                    nb_table_dataGUI(gui.parent,gui.type,object);
                else
                    nb_table_dataGUI(gui.parent,gui.type,object);
                end    
                
            elseif isa(object,'nb_graph_adv')
                
                object = copy(object);
                
                if isa(object.plotter,'nb_graph_ts')
                
                    % Create a graph GUI (time-series)
                    if strcmpi(gui.type,'advanced')
                        nb_graph_tsGUI(gui.parent,gui.type,object);
                    else
                        object = object.plotter;
                        clean(object);
                        applyDefault(gui.parent,object,gui.template);
                        nb_graph_tsGUI(gui.parent,gui.type,object);
                    end

                elseif isa(object.plotter,'nb_table_ts')
                
                    % Create a graph GUI (time-series)
                    if strcmpi(gui.type,'advanced')
                        nb_table_tsGUI(gui.parent,gui.type,object);
                    else
                        object = object.plotter;
                        clean(object);
                        object.position = [0.1000, 0.1000, 0.8000, 0.8000];
                        nb_table_tsGUI(gui.parent,gui.type,object);
                    end    
                    
                elseif isa(object.plotter,'nb_graph_cs')

                    % Create a graph GUI (cross-sectional)
                    if strcmpi(gui.type,'advanced')
                        nb_graph_csGUI(gui.parent,gui.type,object);
                    else
                        object = object.plotter;
                        clean(object);
                        applyDefault(gui.parent,object,gui.template);
                        nb_graph_csGUI(gui.parent,gui.type,object);
                    end
                  
                elseif isa(object.plotter,'nb_table_cs')
                
                    % Create a graph GUI (time-series)
                    if strcmpi(gui.type,'advanced')
                        nb_table_csGUI(gui.parent,gui.type,object);
                    else
                        object = object.plotter;
                        clean(object);
                        object.position = [0.1000, 0.1000, 0.8000, 0.8000];
                        nb_table_csGUI(gui.parent,gui.type,object);
                    end     
                    
                elseif isa(object.plotter,'nb_graph_data')

                    % Create a graph GUI (cross-sectional)
                    if strcmpi(gui.type,'advanced')
                        nb_graph_dataGUI(gui.parent,gui.type,object);
                    else  
                        object = object.plotter;
                        clean(object);
                        applyDefault(gui.parent,object,gui.template);
                        nb_graph_dataGUI(gui.parent,gui.type,object);
                    end 
                    
                elseif isa(object.plotter,'nb_table_data')
                
                    % Create a graph GUI (time-series)
                    if strcmpi(gui.type,'advanced')
                        nb_table_dataGUI(gui.parent,gui.type,object);
                    else
                        object = object.plotter;
                        clean(object);
                        object.position = [0.1000, 0.1000, 0.8000, 0.8000];
                        nb_table_dataGUI(gui.parent,gui.type,object); 
                    end     
                    
                else
                    nb_errorWindow('The copied element cannot be pasted into a graph.')
                    return
                end
                
            elseif isa(object,'nb_dataSource')                
                dataToGUI(gui,object);
            else 
                nb_errorWindow('The copied object cannot be pasted into a graph.')
                return
            end
            
        case {',','.'}
            
            input = nb_pasteFromClipboard(type);
    
            if isempty(input)
                nb_errorWindow('The copied element cannot be converted to time-series data, cross-sectional data or dimensionless data.')
                return
            else

                if iscell(input)
                    try
                        data = nb_cell2obj(input);
                    catch %#ok<CTCH>
                        nb_errorWindow('The copied element cannot be converted to time-series data, cross-sectional data or dimensionless data.')
                        return
                    end
                else
                    nb_errorWindow('The copied element cannot be converted to time-series data, cross-sectional data or dimensionless data.')
                    return
                end

            end
            dataToGUI(gui,data);
            
    end
    
    % Close past window
    %--------------------------------------------------------------
    close(gui.figureHandle.figureHandle)

end

%==========================================================================
function dataToGUI(gui,object)

    if isa(object,'nb_ts')
                
        if gui.table

            % Construct graph object
            graphObject = nb_graph_ts(object);

            % Default plot option
            graphObject = defaultPlotter(gui,graphObject);

            % Create a graph GUI (time-series)
            nb_graph_tsGUI(gui.parent,gui.type,graphObject);

        else

            % Construct table object
            graphObject = nb_table_ts(object);

            % Default plot option
            graphObject = defaultPlotter(gui,graphObject);

            % Create a table GUI (time-series)
            nb_table_tsGUI(gui.parent,gui.type,graphObject);

        end

    elseif isa(object,'nb_cs')

        if gui.table

            % Construct graph object
            graphObject = nb_graph_cs(object);

            % Default plot option
            graphObject = defaultPlotter(gui,graphObject);

            % Create a graph GUI (time-series)
            nb_graph_csGUI(gui.parent,gui.type,graphObject);

        else

            % Construct table object
            graphObject = nb_table_ts(object);

            % Default plot option
            graphObject = defaultPlotter(gui,graphObject);

            % Create a table GUI (time-series)
            nb_table_tsGUI(gui.parent,gui.type,graphObject);

        end

    elseif isa(object,'nb_data')

        if gui.table

            % Construct graph object
            graphObject = nb_graph_data(object);

            % Default plot option
            graphObject = defaultPlotter(gui,graphObject);

            % Create a graph GUI (time-series)
            nb_graph_dataGUI(gui.parent,gui.type,graphObject);    

        else

            % Construct table object
            graphObject = nb_table_ts(object);

            % Default plot option
            graphObject = defaultPlotter(gui,graphObject);

            % Create a table GUI (time-series)
            nb_table_tsGUI(gui.parent,gui.type,graphObject);

        end

    end
    
end

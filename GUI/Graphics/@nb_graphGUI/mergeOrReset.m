function mergeOrReset(gui,hObject,~)
% Syntax:
%
% mergeOrReset(gui,hObject,event)
%
% Description:
%
% Part of DAG. Merge or reset loaded data. Callback function which 
% listening to the 'sendLoadedData' event of the nb_loadDataGUI class
%
% Input:
%
% - hObject : An nb_loadDataGUI object.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    loadedData = hObject.data;
    if isa(loadedData,'nb_modelDataSource')
        loadedData = nb_smart2TS(loadedData.variables);
    end
    if isempty(gui.plotter)

        % Close the current GUI window
        close(gui.figureHandle.figureHandle)
        
        % Now we have loaded in the data we construct 
        % an graph GUI dependent on the data type
        %----------------------------------------------
        if isa(loadedData,'nb_ts')

            if ~gui.table
            
                % Construct graph object
                graphObject = nb_graph_ts(loadedData);

                % Default plot option
                graphObject = defaultPlotter(gui,graphObject);

                % Create a graph GUI (time-series)
                nb_graph_tsGUI(gui.parent,gui.type,graphObject,gui.template);
                
            else
                
                % Construct table object
                graphObject = nb_table_ts(loadedData);

                % Default plot option
                graphObject = defaultPlotter(gui,graphObject);

                % Create a table GUI (time-series)
                nb_table_tsGUI(gui.parent,gui.type,graphObject);
                
            end
            
        elseif isa(loadedData,'nb_data')

            if ~gui.table
            
                % Construct graph object
                graphObject = nb_graph_data(loadedData);

                % Default plot option
                graphObject = defaultPlotter(gui,graphObject);

                % Create a graph GUI (time-series)
                nb_graph_dataGUI(gui.parent,gui.type,graphObject,gui.template);
                
            else
                
                % Construct table object
                graphObject = nb_table_data(loadedData);

                % Default plot option
                graphObject = defaultPlotter(gui,graphObject);

                % Create a table GUI 
                nb_table_dataGUI(gui.parent,gui.type,graphObject);
                
            end
            
        elseif isa(loadedData,'nb_cs')

            if ~gui.table
            
                % Construct graph object
                graphObject = nb_graph_cs(loadedData);

                % Default plot option
                graphObject = defaultPlotter(gui,graphObject);

                % Create a graph GUI (cross-sectional)
                nb_graph_csGUI(gui.parent,gui.type,graphObject,gui.template);
                
            else
                
                % Construct table object
                graphObject = nb_table_cs(loadedData);

                % Default plot option
                graphObject = defaultPlotter(gui,graphObject);

                % Create a table GUI (cross-sectional)
                nb_table_csGUI(gui.parent,gui.type,graphObject);
                
            end
            
        else % nb_cell

            if ~gui.table
                nb_errorWindow('Cannot load a cell object to a graph.')
            else
                
                % Construct table object
                graphObject = nb_table_cell(loadedData);

                % Default plot option
                graphObject = defaultPlotter(gui,graphObject);

                % Create a table GUI (cross-sectional)
                nb_table_cellGUI(gui.parent,gui.type,graphObject);
                
            end    

        end

    else

        resetCallback(gui,[],[],loadedData);

    end

end

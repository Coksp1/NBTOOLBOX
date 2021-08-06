function checkGraphObject(gui,propertyValue)   
% Syntax:
%
% checkGraphObject(gui,propertyValue)   
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isa(propertyValue,'nb_table_data')
          
        if isa(propertyValue,'nb_graph_cs') || isa(propertyValue,'nb_table_cs')
            nb_errorWindow('It is not possible to load up a cross-sectional graph/table to a dimensionless table window.');
            return
        elseif isa(propertyValue,'nb_graph_ts') || isa(propertyValue,'nb_table_ts')
            nb_errorWindow('It is not possible to load up a time-series graph/table to a dimensionless table window.');
            return
        elseif isa(propertyValue,'nb_graph_data') 
            nb_errorWindow('It is not possible to load up a dimensionless graph to a dimensionless table window.');    
            return
        elseif isa(propertyValue,'nb_table_cell') 
            nb_errorWindow('It is not possible to load up a cell table to a dimensionless table window.');    
            return    
        else
            if isa(propertyValue.plotter,'nb_graph_data') || isa(propertyValue,'nb_table_data')
                nb_errorWindow('It is not possible to load up a dimensionless graph/table to a dimensionless table window.');
                return
            elseif isa(propertyValue.plotter,'nb_graph_ts') || isa(propertyValue,'nb_table_ts')
                nb_errorWindow('It is not possible to load up a time-series graph/table to a dimensionless table window.');
                return
            elseif isa(propertyValue.plotter,'nb_graph_data') 
                nb_errorWindow('It is not possible to load up a dimensionless graph to a dimensionless table window.');    
                return 
            elseif isa(propertyValue.plotter,'nb_table_cell') 
                nb_errorWindow('It is not possible to load up a cell table to a dimensionless table window.');    
                return      
            end
        end
        
    end

    % Plot the new graph object in the graph GUI
    % window
    if strcmpi(gui.type,'advanced')  

        newPlotter = propertyValue.plotter;
        newPlotter.setSpecial('figureHandle',   gui.figureHandle,...
                              'fontUnits',      'normalized',...
                              'defaultFigureNumbering',true);                   
        newPlotter.set('position',[.25, .25, .475, .5],...
                       'normalized','axes');
        
    else

        % Set the figure handle of the new graph object
        % and some other settings
        newPlotter = propertyValue;
        newPlotter.setSpecial('figureHandle',   gui.figureHandle,...
                              'fontUnits',         'normalized'); 
        newPlotter.set('page',1);

    end
    
    % Assign the graph GUI window the new object
    try
        newPlotter.graph();
    catch ME

        close(gui.figureHandle.figureHandle);
        if strcmpi(ME.identifier,'nb_graph:LocalVariableError')

            lVars    = regexp(ME.message,'%#\w*','match');
            eMessage = ['The local variable(s) '  lVars{1}];
            for ii = 2:length(lVars)
                eMessage = [eMessage,', ' ,lVars{ii}]; %#ok 
            end
            eMessage = [eMessage, ' is/are deleted. Table cannot be produced.']; 
            nb_errorWindow(eMessage,ME);
        else
            nb_errorWindow('The table object provided is not valid.',ME)
        end
        return
    end
    
    % Update the UI components
    drawnow;
    gui.changed = 0;
    
    % Assign main program object (nb_GUI) and assign it to the graph object
    % to the graph GUI
    newPlotter.parent = gui.parent;
 
end

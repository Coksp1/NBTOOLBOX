function checkGraphObject(gui,propertyValue,type)    
% Syntax:
%
% checkGraphObject(gui,propertyValue,type)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = gui.type;
    end

    if ~isa(propertyValue,'nb_graph_cs')
          
        if isa(propertyValue,'nb_graph_data') || isa(propertyValue,'nb_table_data')
            nb_errorWindow('It is not possible to load up a dimensionless graph/table to a cross sectional graph window.');
            return
        elseif isa(propertyValue,'nb_graph_ts') || isa(propertyValue,'nb_table_ts')
            nb_errorWindow('It is not possible to load up a time-series graph/table to a cross sectional graph window.');
            return
        elseif isa(propertyValue,'nb_table_cs') 
            nb_errorWindow('It is not possible to load up a cross-sectional table to a cross sectional graph window.');    
            return
        elseif isa(propertyValue,'nb_table_cell') 
            nb_errorWindow('It is not possible to load up a cell table to a cross sectional graph window.');    
            return      
        else
            if isa(propertyValue.plotter,'nb_graph_data') || isa(propertyValue,'nb_table_data')
                nb_errorWindow('It is not possible to load up a dimensionless graph/table to a cross sectional graph window.');
                return
            elseif isa(propertyValue.plotter,'nb_graph_ts') || isa(propertyValue,'nb_table_ts')
                nb_errorWindow('It is not possible to load up a time-series graph/table to a cross sectional graph window.');
                return
            elseif isa(propertyValue.plotter,'nb_table_cs') 
                nb_errorWindow('It is not possible to load up a cross-sectional table to a cross sectional graph window.');    
                return
            elseif isa(propertyValue.plotter,'nb_table_cell') 
                nb_errorWindow('It is not possible to load up a cell table to a cross sectional graph window.');    
                return     
            end
        end
        
    end

    % Set some properties
    if strcmpi(type,'advanced')  
        newPlotter = propertyValue.plotter;
    else
        newPlotter = propertyValue;
    end
    
    % Assign main program object (nb_GUI) and assign it to the graph object
    % to the graph GUI
    for ii = 1:size(newPlotter,2)
        newPlotter(ii).parent = gui.parent;
        assignTemplates(gui,newPlotter(ii));
    end
    
    % Secure current template (for backward compatibility)
    if ~isempty(newPlotter(1).currentTemplate)
        % The template may have been changed by using nb_graphSettings
        secureTemplate(gui,newPlotter);
        %applyTemplate(newPlotter,newPlotter.currentTemplate);
    end
    
    for ii = 1:size(newPlotter,2)
    
        newPlotter(ii).set('page',1); 
        newPlotter(ii).setSpecial('figureHandle',gui.figureHandle,...
                                  'defaultFigureNumbering',true); 

        % Get the legend information (The GUI uses the legendText property 
        % instead of the legends property)
        updateLegendInformation(newPlotter(ii));

        % Assign the graph GUI window the new object
        try
            newPlotter(ii).graph();
        catch ME

            close(gui.figureHandle.figureHandle);

            if strcmpi(ME.identifier,'nb_graph:LocalVariableError')

                lVars    = regexp(ME.message,'%#\w*','match');
                eMessage = ['The local variable(s) '  lVars{1}];
                for jj = 2:length(lVars)
                    eMessage = [eMessage,', ' ,lVars{jj}]; %#ok 
                end
                eMessage = [eMessage, ' is/are deleted. Graph cannot be produced.'];  %#ok<AGROW>
                nb_errorWindow(eMessage,ME);
            else
                nb_errorWindow('The graph object provided is not valid.',ME)
            end
            return
        end
        
    end
    
    % Update the UI components
    enableUIComponents(gui,newPlotter(1),[]);
    gui.changed = 0;
 
end

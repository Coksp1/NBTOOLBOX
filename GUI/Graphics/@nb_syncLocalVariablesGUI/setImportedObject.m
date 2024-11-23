function setImportedObject(gui,exLocVars)
% Syntax:
%
% setImportedObject(gui,hObject,event)
%
% Description:
%
% Part of DAG. Assign object the concatenated local variables
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj = gui.object;
    if isa(obj,'nb_graph_obj')
        
        % Sets both the graph object and its data source if it is a nb_ts object
        setSpecial(obj,'localVariables',exLocVars); 
        
    elseif isa(obj,'nb_graph_adv')
        
        % Sets both the graph object and its data source if it is a nb_ts object
        setSpecial(obj,'localVariables',exLocVars);
        
    elseif isa(obj,'nb_graph_subplot')
        
        for ii = 1:length(obj.graphObjects)
            setSpecial(obj.graphObjects{ii},'localVariables',exLocVars);
        end
        
    elseif isa(obj,'nb_graph_package')

        graphs = obj.graphs;
        for ii = 1:size(graphs,2)
            setSpecial(graphs{ii},'localVariables',exLocVars);
        end

    else % nb_ts, nb_cs or nb_data
        
        obj.localVariables = exLocVars;

        % As the nb_ts/nb_cs/nb_data object is a value class we need to 
        % assign the changes to the data in a callback
        gui.funcHandle(gui);
        
    end
    
    notify(gui,'syncDone')

end

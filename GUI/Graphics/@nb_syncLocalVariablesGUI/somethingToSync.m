function somethingToSync(gui)
% Syntax:
%
% somethingToSync(gui)
%
% Description:
%
% Part of DAG. Check if the object need to be synced, and if so create a 
% dialog window to select which version to keep. (Existing or loaded)
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isa(gui.object,'nb_graph_package')
        object = gui.object.graphs{1};
    elseif isa(gui.object,'nb_graph_subplot')
        object = gui.object.graphObjects{1};
    else
        object = gui.object;
    end

    % Check the localVariables property
    %--------------------------------------------------------------
    exLocVars  = gui.parent.settings.localVariables; % Is a handle so don't need to assign it back later
    if ~nb_isempty(object.localVariables)
    
        locVars    = object.localVariables;
        varsEx     = fieldnames(exLocVars);
        varsLoaded = fieldnames(locVars);
        found      = ismember(varsLoaded,varsEx);
        varsFound  = varsLoaded(found);
        varsNew    = varsLoaded(~found);
        
        % Append the new local variables found
        for ii = 1:length(varsNew)
            
            exLocVars.(varsNew{ii}) = locVars.(varsNew{ii});
            
        end
        
        % Check if there is some conflict of some of the local
        % variables
        for ii = 1:length(varsFound)
            
            ex   = exLocVars.(varsFound{ii});
            new  = locVars.(varsFound{ii});
            same = isequal(ex,new);
            if ~same
                
                gui.conflictingNames = [gui.conflictingNames, varsFound{ii}];
                gui.existing         = [gui.existing, ex];
                gui.added            = [gui.added, new];
                
            end
            
        end
        
    end
    
    % Make dialog window if there exist some conflicting local
    % variables
    %--------------------------------------------------------------
    if ~isempty(gui.conflictingNames)
        makeGUI(gui);
    else
        
        % Assign object the concatenated local variables
        setImportedObject(gui,exLocVars);
        
    end

end

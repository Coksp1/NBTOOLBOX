function overwrite(gui,~,~)
% Syntax:
%
% overwrite(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Check the localVariables property
    %--------------------------------------------------------------
    conflNames = {};
    object     = gui.plotter;
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
                conflNames = [conflNames, varsFound{ii}]; %#ok<AGROW>
            end
            
        end
        
    end
    
    if ~isempty(conflNames)
        syncGui = nb_syncLocalVariablesGUI(gui.parent,object);
        addlistener(syncGui,'syncDone',@gui.finishUp);
    else
        finishUp(gui,[],[]);
    end
    
end

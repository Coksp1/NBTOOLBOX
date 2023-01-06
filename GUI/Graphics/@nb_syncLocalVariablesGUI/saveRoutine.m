function saveRoutine(gui,~,~)
% Syntax:
%
% saveRoutine(gui,hObject,event)
%
% Description:
%
% Part of DAG. Resolve local variables which are conflicting and save 
% to main program
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    tableData = get(gui.table,'data');
    logi      = cell2mat(tableData(:,end));
    locVars   = gui.conflictingNames;
    ex        = gui.existing;
    loaded    = gui.added;
    exLocVars = gui.parent.settings.localVariables;
    for ii = 1:size(logi,1)
       
        if logi(ii)
            exLocVars.(locVars{ii}) = ex{ii};
        else
            exLocVars.(locVars{ii}) = loaded{ii};
        end
        
    end
    
    % Close window
    delete(gui.figureHandle);
    
    % Assign object the concatenated local variables
    setImportedObject(gui,exLocVars);
    
end

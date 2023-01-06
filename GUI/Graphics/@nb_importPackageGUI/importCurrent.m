function importCurrent(gui)
% Syntax:
%
% importCurrent(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Check for invalid identifiers
    identifiers                       = gui.package.identifiers;
    [gui.package.identifiers,message] = nb_checkSaveName(identifiers);
    if ~isempty(message)
        nb_errorWindow('The loaded package includes invalid identifiers and cannot be loaded!')
        return
    end
    
    % Check for conflicting identifiers
    identifiers = gui.package.identifiers;
    stored      = fieldnames(gui.parent.graphs);
    ind         = ismember(identifiers,stored);
    if any(ind)
        nb_confirmWindow(['To load the package the following graphs will be overwritten; ' nb_cellstr2String(identifiers(ind),', ',' and ') '.'...
            'Are you sure you want to continue?'],@notSaveCurrent,@gui.saveCurrent,[gui.parent.guiName ': Import Package'])
    else
        saveCurrent(gui,[],[]);
    end
      
end

%==========================================================================
function notSaveCurrent(hObject,~)
    close(get(hObject,'parent'));   
end
    

function renameVariableCallback(gui,~,~)
% Syntax:
%
% renameVariableCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the expression to evaluate and the the variable name
    if isequal(get(gui.renamepopup,'value'),1)
        list     = get(gui.popupmenu,'string');
        index    = get(gui.popupmenu,'value');
        selected = list{index};
    else
        selected = get(gui.idBox,'string');
    end
    
    % Get/check the new name of the variable, and allow for removal of 
    % identifier by giving a space as the new name
    newName = get(gui.editbox,'string');
    if isempty(newName)
        nb_errorWindow(['New name of ' gui.type ' cannot be empty.'])
        return
    end
%     if get(gui.renamepopup,'value') == 1 
%         [newName,message] = nb_checkSaveName(newName,1);
%         if ~isempty(message)
%             nb_errorWindow(['New name not valid, Error: ' message]);
%             return
%         end
%     end
    
    % Prevent names starting with a number
    firstLetter = newName(1,1);
    firstLetter = str2double(firstLetter);
    if ~isnan(firstLetter)
        nb_errorWindow(['New name of ' gui.type ' cannot start with an number.'])
        return
    end
    
    % Check if identify is valid
    identifier = get(gui.idBox,'string');
    if isempty(identifier) && isequal(selected,get(gui.idBox,'string'))
        nb_errorWindow('Identifier cannot be empty')
        return
    end
    
    if isequal(selected,get(gui.idBox,'string'))
        firstSign = identifier(1,1);
        lastSign = identifier(1,end);
        
        
        if ~isequal(firstSign,'*') && ~isequal(lastSign,'*')
            nb_errorWindow('Identifier must start or end with *')
            return
        end
        
    end
    
    % Get list of variables/types/datasets
    switch lower(gui.type)
        
        case 'variable'

            list = gui.data.variables;

        case 'page'

            list = gui.data.dataNames;

        case 'type'

            list = gui.data.types;
    end

    if ~isempty(find(strcmp(newName,list),1))
        nb_errorWindow([gui.type ' ''' newName ''' already exist.']);
        return
    end
    
    % Evaluate the expression
    try
        gui.data = gui.data.rename(gui.type,selected,newName);
    catch %#ok<CTCH>
        nb_errorWindow(['New name not valid, Error: ' message]);
        return
    end
    
    % Notify listeners
    notify(gui,'methodFinished');
    
    % Update the pop-up menu
    switch lower(gui.type)
        
        case 'variable'

            list = gui.data.variables;

        case 'page'

            list = gui.data.dataNames;

        case 'type'

            list = gui.data.types;
    end
    
    set(gui.popupmenu,'string',list,'value',1);

end  

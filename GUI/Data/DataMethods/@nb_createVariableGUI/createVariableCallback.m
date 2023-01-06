function createVariableCallback(gui,~,~)
% Syntax:
%
% createVariableCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. The function called when the create button is pushed in the
% variable manager window.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the expression to evaluate and the the variable name
    expression = get(gui.editbox1,'string');
    if isempty(expression)
        return
    end

    % Get the name of the varible if given
    nameOfNewVariable = get(gui.editbox2,'string');
    if isempty(nameOfNewVariable)
        nameOfNewVariable = expression;
    end
    
    [nameOfNewVariable, message] = nb_checkSaveName(nameOfNewVariable,1);
    if ~isempty(message);
        nb_errorWindow(['Bad variable name, Error: ' message]);
        return
    end
    
    % Evaluate the expression
    switch lower(gui.type)
        case 'variable'
            try
                gui.data = gui.data.createVariable(nameOfNewVariable,expression);
            catch %#ok<CTCH>

                if ~isempty(find(strcmp(nameOfNewVariable,gui.data.variables),1))
                    nb_errorWindow(['Variable ''' nameOfNewVariable ''' already exist.']);
                else
                    nb_errorWindow(['Could not evaluate the expression ''' expression '''.']);
                end
                return
            end

        case 'type'
            try
                gui.data = gui.data.createType(nameOfNewVariable,expression);
            catch %#ok<CTCH>
                
                if ~isempty(find(strcmp(nameOfNewVariable,gui.data.variables),1))
                    nb_errorWindow(['Type ''' nameOfNewVariable ''' already exist.']);
                else
                    nb_errorWindow(['Could not evaluate the expression ''' expression '''.']);
                end
                return
            end
        

     end

    % Notify listeners
    notify(gui,'methodFinished');
end


function setValue(gui,hObject,~)
% Syntax:
%
% setValue(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;

    % Get type
    string = gui.types;
    index  = get(gui.typepopup,'value');
    type   = string{index};
    
    % Get variable
    string = get(gui.varpopup,'string');
    index  = get(gui.varpopup,'value');
    var    = string{index};
    
    % Get selected string
    string = get(hObject,'string');
    
    % Check input (can be local variables)
    [newValue,message] = nb_interpretDateObsTypeInputGUI(plotterT,string);
    if ~isempty(message)
        nb_errorWindow(message);
        return
    end
    
    % Set property
    nanVars = plotterT.nanVariables;
    index   = find(strcmpi(var,nanVars(1:2:end)),1);
    switch lower(type)
        
        case 'before'
            nanVars{index*2}{2} = newValue;
        case 'after'
            nanVars{index*2}{2} = newValue;
        case 'beforeandafter'
            if hObject == gui.editBox1
                nanVars{index*2}{2} = newValue;
            else
                nanVars{index*2}{3} = newValue;
            end
        case 'between'
            if hObject == gui.editBox1
                nanVars{index*2}{2} = newValue;
            else
                nanVars{index*2}{3} = newValue;
            end
    end
    
    plotterT.nanVariables = nanVars;  

    % Notify listeners
    notify(gui,'changedGraph');

end

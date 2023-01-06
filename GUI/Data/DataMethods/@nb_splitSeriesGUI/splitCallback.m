function splitCallback(gui,hObject,~)
% Syntax:
%
% splitCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the variable and the date
    string  = get(gui.variables,'string');
    index   = get(gui.variables,'value');
    var     = string(index);
    string  = get(gui.dates,'string');
    index   = get(gui.dates,'value');
    date    = string{index};
    postfix = get(gui.postfix,'string');
    if isempty(postfix)
        nb_errorWindow('The postfix cannot be empty')
        return
    end
    overlap = get(gui.overlapping,'value');
    
    % Evaluate the expression   
    try
        gui.data = splitSeries(gui.data,var,date,postfix,overlap);
    catch Err
        nb_errorWindow('Could not split the selected variable(s). Please see error below.', Err)
    end
    
    % Close window
    close(get(get(hObject,'parent'),'parent'));
    
    % Notify listeners
    notify(gui,'methodFinished');

end

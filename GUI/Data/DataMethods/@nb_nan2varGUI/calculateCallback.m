function calculateCallback(gui,~,~)
% Syntax:
%
% calculateCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the selected options
    string  = get(gui.pop1,'string');
    index   = get(gui.pop1,'value');
    var     = string{index};
    string  = get(gui.list1,'string');
    index   = get(gui.list1,'value');
    vars    = string(index);
    
    % Evaluate the expression
    try  
        gui.data = nan2var(gui.data,vars,var);
    catch 
        nb_errorWindow('Error while assigning nan values. (Be aware: This method does not support multi-paged datasets.)')
        return
    end
    
    % Notify listeners
    notify(gui,'methodFinished');
    
    % Close window
    close(gui.figureHandle);

end

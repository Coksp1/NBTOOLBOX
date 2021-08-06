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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the periods selected
    vars    = nb_getUIControlValue(gui.list1);
    periods = nb_getUIControlValue(gui.edit1,'numeric');
    if isempty(periods) || isnan(periods)
        nb_errorWindow('The periods input must be an integer')
        return
    elseif ~nb_iswholenumber(periods)
        nb_errorWindow('The periods input must be an integer')
        return
    end
    
    % Evaluate the expression
    try
        gui.data = shrinkSample(gui.data,vars,periods);
    catch Err
        nb_errorWindow('Could not evaluate method. Please see error below.',Err)
        return
    end
          
    % Notify listeners
    notify(gui,'methodFinished');
    
    % Close window
    close(gui.figureHandle);

end

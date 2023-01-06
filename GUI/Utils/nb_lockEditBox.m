function nb_lockEditBox(box,event,oldString)
% Syntax:
%
% nb_lockEditBox(box,event,oldString)
%
% Description:
%
% A function to lock the contents of an editbox made using uicontrol. Can
% be used to prevent users from editing resultwindows etc. Requires the
% input oldString, which is the string that the editbox is locked to
% display. 
%
% Designed to be used by the keypressfcn property of a uicontrol object.
% 
% Input:
% 
% - box       : Handle to the uicontrol.
%
% - event     : The triggered event.
%
% - oldString : The old string to be kept whatever the user do.
% 
% Written by Eyo I. Herstad

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Allow the user to use some shortcuts
    if isempty(event)
       allowable = false;
    else
        if ~isempty(event.Modifier)
            markAll = strcmpi(event.Key,'a') && strcmpi(event.Modifier,'control');
            copy = strcmpi(event.Key,'c') && strcmpi(event.Modifier,'control');
            harmlessKey = strcmpi(event.Key,'control') || strcmpi(event.Key,'shift') || strcmpi(event.Key,'alt');
        else
            markAll = false;
            copy = false;
            harmlessKey = strcmpi(event.Key,'pagedown') || strcmpi(event.Key,'pageup') || ...
                strcmpi(event.Key,'capslock') || strcmpi(event.Key,'windows') || ...
                strcmpi(event.Key,'downarrow') || strcmpi(event.Key,'uparrow') || ...
                strcmpi(event.Key,'leftarrow') || strcmpi(event.Key,'rightarrow');
        end
        
        allowable = markAll || copy || harmlessKey;
    end
    
    % Set the text of the object to the text that hasn't been edited.
    if ~allowable
        set(box,'string',oldString);
    end
    
end


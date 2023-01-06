function convertCallback(gui,hObject,~)
% Syntax:
%
% convertCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Inputs
    if isa(gui.data,'nb_cs')
        inputs = {};
    elseif isa(gui.data,'nb_data')
        inputs = {nb_getUIControlValue(gui.strip)};
    else
        format = nb_getUIControlValue(gui.format);
        strip  = nb_getUIControlValue(gui.strip);
        inputs = {format,strip};
    end
    
    % Evaluate the expression
    try
        gui.data = tonb_cell(gui.data,inputs{:});
    catch Err
        nb_errorWindow('Could not convert to a cell object.', Err)
        return
    end
    
    % Close window
    close(get(hObject,'parent'));
    
    % Notify listeners
    notify(gui,'methodFinished');

end

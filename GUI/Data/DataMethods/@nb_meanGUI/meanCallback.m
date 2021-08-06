function meanCallback(gui,hObject,~)
% Syntax:
%
% meanCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the inputs
    dim    = nb_getUIControlValue(gui.popupmenu1,'numeric');
    output = nb_getUIControlValue(gui.popupmenu2);
    func   = str2func(lower(gui.type));
    
    % Do the calculation
    try
        switch output
            case 'Time-Series'
                gui.data = func(gui.data,'nb_ts',dim);
            case 'Dimensionless'
                gui.data = func(gui.data,'nb_data',dim);
            case 'Cross-Sectional'
                gui.data = func(gui.data,'nb_cs',dim);
        end
    catch Err
        nb_errorWindow('Error:',Err)
        return
    end
    
    % Close window
    delete(get(hObject,'parent'));
    
    % Notify listeners
    notify(gui,'methodFinished');

end  

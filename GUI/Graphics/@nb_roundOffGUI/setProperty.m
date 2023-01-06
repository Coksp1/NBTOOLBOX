function setProperty(gui,hObject,~)
% Syntax:
%
% setProperty(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback function for setting the properties
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    plotterAdv = gui.plotter;
    string     = get(hObject,'string');
    if isempty(string)
        value = [];
    else
        value   = round(str2double(string));
        if isnan(value)
            nb_errorWindow(['The round-off option must be set to an integer. Is ' string '.'])
            return
        elseif value < 0
            nb_errorWindow(['The round-off option must be set to an integer greater then or equal to 0. Is ' string '.']) 
            return
        end
        set(hObject,'string',int2str(value));
    end
    plotterAdv.roundoff = value;

    % Notify listeners
    notify(gui,'changedGraph');

end


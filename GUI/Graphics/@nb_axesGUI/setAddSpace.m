function setAddSpace(gui,hObject,~,index)
% Syntax:
%
% setAddSpace(gui,hObject,event,index)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the value selected
    strs    = get(hObject,'string');
    value   = str2double(strs);

    if isnan(value)
        nb_errorWindow(['The X-Axis Add Space (' int2str(index) ') must be set to a number between 0 and 1.'])
        return
    elseif value < 0 || value > 1
        nb_errorWindow(['The X-Axis Add Space (' int2str(index) ') must be set to a number between 0 and 1.'])
        return
    end
        
    % Set the plotter object
    gui.plotter.addSpace(index) = value;

    % Udate the graph
    notify(gui,'changedGraph');

end

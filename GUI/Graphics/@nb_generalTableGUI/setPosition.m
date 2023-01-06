function setPosition(gui,hObject,~,index)
% Syntax:
%
% setPosition(gui,hObject,event,index)
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
        nb_errorWindow(['The position(' int2str(index) ') of the axes must be a number between 0 and 1.'])
        return
    elseif value < 0 || value > 1
        nb_errorWindow(['The position(' int2str(index) ') of the axes must be a number between 0 and 1.'])
        return
    end
        
    % Set the plotter object
    gui.plotter.position(index) = value;

    % Udate the graph
    notify(gui,'changedGraph');
    
end

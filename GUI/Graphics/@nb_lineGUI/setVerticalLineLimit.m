function setVerticalLineLimit(gui,hObject,~,type)
% Syntax:
%
% setVerticalLineLimit(gui,hObject,event,type)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if strcmpi(type,'lower')
        ind = 1;
    else
        ind = 2;
    end

    plotterT = gui.plotter;

    % Get selected value
    string = get(hObject,'string');
    limit  = str2double(string);
    
    if isnan(limit)
        nb_errorWindow(['The ' type ' limit of the vertical line must be set to a number.'])
        return
    end
    
    % Assign changes
    index       = get(gui.popupmenu1,'value');
    limits      = plotterT.verticalLineLimit{index};
    limits(ind) = limit;
    plotterT.verticalLineLimit{index} = limits;  

    % Notify listeners
    notify(gui,'changedGraph');

end

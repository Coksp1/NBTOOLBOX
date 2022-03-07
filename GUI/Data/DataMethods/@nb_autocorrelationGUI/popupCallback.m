function popupCallback(gui,~,~)
% Syntax:
%
% popupCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Function called when the popupmenu changes.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    index  = get(gui.methodBox,'value');
    string = get(gui.methodBox,'string');
    method = string{index};

    switch lower(method) 
        case 'parametric bootstrap'
            enable = 'on';
        otherwise
            enable = 'off';
    end

    set(gui.maxARBox,'enable',enable);
    set(gui.maxMABox,'enable',enable);
    set(gui.algorithmBox,'enable',enable);
    set(gui.criteriaBox,'enable',enable);

end


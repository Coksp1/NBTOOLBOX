function setAlignAxes(gui,hObject,~)
% Syntax:
%
% setAlignAxes(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    tag = get(hObject,'tag');
    ind = str2double(tag);
    
    string = get(hObject,'string');
    value  = str2double(string);
    if isempty(string)
        value = [];
    elseif isnan(value) && ~isempty(string)
        nb_errorWindow('The align axes at value option must be set to a number.')
        return
    end
    
    old = gui.plotter.alignAxes;
    if isempty(old)
        if ind == 2
            nb_errorWindow('You need to set the first align value before setting the second align value (right-axes) when both are empty.')
            set(hObject,'string','')
            return
        end
    elseif isscalar(old)
        if ind == 2
            value = [old,value];
        end
    else
        if ind == 1 && isempty(value)
            set(hObject,'string',num2str(old(1)))
            nb_errorWindow('You need to set the second align value (right-axes) to empty before setting the first align value to empty.')
            return
        end
        if isempty(value)
            value = old(1);
        else
            old(ind) = value;
            value    = old;
        end
    end

    gui.plotter.alignAxes = value;
    
    % Udate the graph
    notify(gui,'changedGraph');

end

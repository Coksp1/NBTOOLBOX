function setFakeLegendLineWidth(gui,hObject,~)
% Syntax:
%
% setFakeLegendLineWidth(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the current fake legend
    string = get(gui.popupmenu2,'string');
    index  = get(gui.popupmenu2,'value');
    fakeL  = string{index};
    
    % Locate the fake legend in the graph object
    plotterT = gui.plotter;
    fakeLs   = plotterT.fakeLegend;
    indF     = find(strcmp(fakeL,fakeLs),1,'last');
    options  = fakeLs{indF + 1};
    
    % Get the selected value
    string   = get(hObject,'string');
    num      = str2double(string);
    
    if isnan(num)
        nb_errorWindow(['The selected line width must be a number greater then 0. Is ' string '.'])
        return
    elseif num <= 0
        nb_errorWindow(['The selected line width must be a number greater then 0. Is ' string '.'])
        return
    end
    
     % Assign changes
    ind = find(strcmpi('lineWidth',options),1,'last');
    if isempty(ind)
        options = [options,'lineWidth',num];
    else
        options{ind + 1} = num;
    end
    fakeLs{indF + 1} = options;
    
    % Update graph object
    plotterT.fakeLegend = fakeLs;
    
    % Notify listeners
    notify(gui,'changedGraph');

end

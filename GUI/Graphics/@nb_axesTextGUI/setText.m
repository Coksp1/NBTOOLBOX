function setText(gui,hObject,~)
% Syntax:
%
% setText(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get value selected
    string = get(hObject,'string');
    ind    = strfind(string,'\\');
    if ~isempty(ind)
        string = regexp(string,'\s\\\\\s','split');
        string = char(string);
    end
    
    % Assign graph object
    plotterT = gui.plotter;
    switch lower(gui.type)
        case 'title'
            plotterT.title = string;
        case 'xlabel'
            plotterT.xLabel = string;
        case 'ylabel'
            plotterT.yLabel = string;
        otherwise
            plotterT.yLabelRight = string;
    end
    
    % Notify listeners
    notify(gui,'changedGraph');

end

function selectLineStyle2(gui,hObject,~)
% Syntax:
%
% selectLineStyle2(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
            
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;

    % Get selected variable
    string  = get(gui.popupmenu1,'string');
    index   = get(gui.popupmenu1,'value');
    var     = string{index};

    % Get selected line style
    lineStyles = get(hObject,'string');   
    index      = get(hObject,'value');
    lineS      = lineStyles{index};

    % Update the graph object
    ind                          = find(strcmp(var,plotterT.lineStyles),1,'last'); 
    lineStyle                    = plotterT.lineStyles{ind + 1};
    lineStyle{3}                 = lineS;
    plotterT.lineStyles{ind + 1} = lineStyle;
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');

end

function selectScatterType1(gui,hObject,~)
% Syntax:
%
% selectScatterType1(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback when scatter variable 1 is changed
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get selected variable
    string   = get(hObject,'string');
    index    = get(hObject,'value');
    selected = string{index};

    % Get the scatter groupes
    plotterT = gui.plotter;
    switch lower(gui.scatterSide)
        case 'left'
            scaT     = plotterT.scatterTypes;
            scaT{1}  = selected;  
            plotterT.set('scatterTypes', scaT);
        case 'right'
            scaT     = plotterT.scatterTypesRight;
            scaT{1}  = selected;  
            plotterT.set('scatterTypesRight', scaT);
    end
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');

end

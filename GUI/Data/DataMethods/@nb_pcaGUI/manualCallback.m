function manualCallback(gui,hObject,~)
% Syntax:
%
% manualCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    value = get(hObject,'value');
    if value
        visible1 = 'on';
        visible2 = 'off';
    else
        visible1 = 'off';
        visible2 = 'on';
    end

    set(gui.components.nFactorsText,'visible',visible1);
    set(gui.components.nFactors,'visible',visible1);
    set(gui.components.maxFactors,'enable',visible2);
    set(gui.components.criteriaText,'visible',visible2);
    set(gui.components.criteria,'visible',visible2);
    
end

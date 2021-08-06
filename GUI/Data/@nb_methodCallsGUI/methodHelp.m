function methodHelp(gui,~,~)
% Syntax:
%
% methodHelp(gui,hObject,event)
%
% Description:
%
% Part of DAG. Get help on method callback.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    index = gui.selectedCells;
    if isempty(index)
        return;
    end
    
    data       = get(gui.table,'data');
    methodRow  = data(index(1,1), :);
    methodName = methodRow{1};
    
    % First argument to extMethod selected?
    if strcmpi(methodName, 'extMethod') && index(2,1) == 2
        methodName = methodRow{2};
    end
    
    methodPath = which([methodName '(' class(gui.data) ')']);
    doc(methodPath);
    
end

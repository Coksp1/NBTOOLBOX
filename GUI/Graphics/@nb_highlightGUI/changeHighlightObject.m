function changeHighlightObject(gui,hObject,~)
% Syntax:
%
% changeHighlightObject(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen          
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    string = get(hObject,'string');
    index  = get(hObject,'value');
    object = string{index};

    if strcmpi(object,' ')
        return
    end
    
    % Update the GUI with the option for the new highlight object
    updatePanel(gui,object,1);

end

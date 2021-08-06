function changeVariable(gui,hObject,~)
% Syntax:
%
% changeVariable(gui,hObject,event)
%
% Description:
%
% Part of DAG. Change the variable to remove observation of in the GUI 
% 
% Written by Kenneth S�terhagen Paulsen    
    
% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    string = get(hObject,'string');
    index  = get(hObject,'value');
    object = string{index};
    
    % Update the GUI with the option for the new variable
    updatePanel(gui,object);

end

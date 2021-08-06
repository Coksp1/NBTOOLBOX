function changePatchObject(gui,hObject,~)
% Syntax:
%
% changePatchObject(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen
 
% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    string = get(hObject,'string');
    index  = get(hObject,'value');
    object = string{index};

    if strcmpi(object,' ')
        return
    end
    
    % Update the GUI with the option for the new highlight object
    updatePatchPanel(gui,object,1);

end

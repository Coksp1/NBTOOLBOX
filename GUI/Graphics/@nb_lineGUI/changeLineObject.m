function changeLineObject(gui,hObject,~)
% Syntax:
%
% changeLineObject(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen           
    
% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    string     = get(hObject,'string');
    index      = get(hObject,'value');
    lineObject = string{index};

    if strcmpi(lineObject,' ')
        return
    end
    
    % Update the GUI with the option for the new variable
    updateLinePanel(gui,lineObject,1);

end

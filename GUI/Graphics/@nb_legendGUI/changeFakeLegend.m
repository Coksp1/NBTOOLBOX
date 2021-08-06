function changeFakeLegend(gui,hObject,~)
% Syntax:
%
% changeFakeLegend(gui,hObject,event)
%
% Description:
%
% Part of DAG. Change the fake legend of the fake legend panel 
% 
% Written by Kenneth Sæterhagen Paulsen       
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    string     = get(hObject,'string');
    index      = get(hObject,'value');
    fakeLegend = string{index};

    if strcmpi(fakeLegend,' ')
        return
    end
    
    % Update the GUI with the option for the new variable
    updateFakeLegendPanel(gui,fakeLegend,1);

end

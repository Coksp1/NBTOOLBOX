function changeGraph(gui,hObject,~)
% Syntax:
%
% changeGraph(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    string    = get(hObject,'string');
    index     = get(hObject,'value');
    graphName = string{index};
    
    sGraphObj = gui.infoStruct.(gui.name);
    % User may go from a panel graph to a regular graph. In that case we do
    % not want to still have plotter(2) edit boxes + text
    if sGraphObj.panel
        delete(gui.editBox13)
        delete(gui.editBox14)
        delete(gui.editBox15)
        delete(gui.editBox16)
        delete(gui.uiText1)
        delete(gui.uiText2)
        delete(gui.uiText3)
        delete(gui.uiText4)
        delete(gui.uiText5)
        delete(gui.uiText6)
    end

    % Update the GUI properties
    graphs       = gui.infoStruct;
    gui.graphObj = graphs.(graphName);
    gui.name     = graphName;
    
    % Call from addLeftColumnGUI in the change. Window and change graph
    % popupmenu remains constant
    addLeftColumnGUI(gui);

end

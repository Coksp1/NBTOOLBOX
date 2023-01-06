function rand(gui,~,~,type)
% Syntax:
%
% rand(gui,hObject,event,type)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    switch type
        case 'nb_ts'
            initialData = nb_ts();
        case 'nb_cs'
            initialData = nb_cs();
        case 'nb_data'
            initialData = nb_data();
        case 'nb_cell'
            initialData = nb_cell();
    end
    
    generateDataGUI = nb_generateDataGUI(gui, initialData);
    addlistener(generateDataGUI, 'methodFinished', @(src,event) updateData(gui,src));
end

function updateData(gui, generateDataGUI)
    gui.data = generateDataGUI.data;
    if isa(gui.parent,'nb_GUI')
        gui.data.localVariables = gui.parent.settings.localVariables;
    end
    gui.changed = 1;  
    notify(gui, 'updatedData');
end

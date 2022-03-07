function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the handle to the main program
    mainGUI = gui.parent;

    % Create window
    if isa(mainGUI,'nb_GUI')
        name = [mainGUI.guiName ': Re-order ' gui.type];
    else
        name = ['Re-order ' gui.type];
    end
    
    if strcmpi(gui.type,'variables')
        list1 = gui.data.variables;
    elseif strcmpi(gui.type,'datasets')
        list1 = gui.data.dataNames;
    else
        list1 = gui.data.types;
    end
    
    reorderGui = nb_reorderGUI(list1,name);
    addlistener(reorderGui,'reorderingFinished',@gui.reorderCallback);

end

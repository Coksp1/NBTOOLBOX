function pasteCallback(gui,~,~)
% Syntax:
%
% pasteCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Paste locally copied object to selection.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    sel = gui.selectedCells;
    if isempty(sel)
        return 
    end

    if isempty(gui.copied)
        nb_errorWindow('No distribution is copied!')
        return
    end
    
    indD = sel(:,1);
    indV = sel(:,2);
    for ii = length(indV)    
        for jj = 1:length(indD)
            gui.distributions(indD(jj),indV(ii)) = copy(gui.copied);
        end
    end
    
    gui.addToHistory();
    gui.updateGUI();
    
end

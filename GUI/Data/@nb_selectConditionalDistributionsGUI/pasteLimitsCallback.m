function pasteLimitsCallback(gui,~,~)
% Syntax:
%
% pasteLimitsCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Paste locally copied object to selection.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    sel = gui.selectedCells;
    if isempty(sel)
        return 
    end

    indD = sel(:,1);
    indV = sel(:,2);
    for ii = length(indV)    
        for jj = 1:length(indD)
            set(gui.distributions(indD(jj),indV(ii)),'lowerBound',gui.copiedLimits{2},...
                                                     'upperBound',gui.copiedLimits{4});
        end
    end
    gui.updateGUI();

end

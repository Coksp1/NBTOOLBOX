function pasteModeAdjustedCallback(gui,~,~)
% Syntax:
%
% pasteModeAdjustedCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Paste locally copied object to selection and 
% adjusting the mode.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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
            temp     = copy(gui.copied);
            m        = mode(temp);
            mCurrent = mode(gui.distributions(indD(jj),indV(ii)));
            shift    = mCurrent-m;
            if ~isempty(temp.meanShift)
                shift = shift + temp.meanShift;
            end
            temp.set('meanShift',shift)
            gui.distributions(indD(jj),indV(ii)) = temp;
        end
    end
    
    gui.addToHistory();
    gui.updateGUI();

end

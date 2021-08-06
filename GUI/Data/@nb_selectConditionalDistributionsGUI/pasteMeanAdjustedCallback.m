function pasteMeanAdjustedCallback(gui,~,~)
% Syntax:
%
% pasteMeanAdjustedCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Paste locally copied object to selection and adjusting 
% the mean.
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
            temp     = copy(gui.copied);
            m        = mean(temp);
            mCurrent = mean(gui.distributions(indD(jj),indV(ii)));
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

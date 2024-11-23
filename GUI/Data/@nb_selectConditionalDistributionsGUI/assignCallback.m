function assignCallback(gui,~,~)
% Syntax:
%
% assignCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Assign imported distribution to the selected distributions.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    vars     = nb_getSelectedFromListbox(gui.variablesListBox);
    [~,indV] = ismember(vars,gui.variables);
    datesT   = nb_getSelectedFromListbox(gui.datesListBox);
    [~,indD] = ismember(datesT,gui.dates);

    if get(gui.meanShiftRadiobutton,'value')
        for ii = length(indV)    
            for jj = 1:length(indD)
                temp     = copy(gui.loaded);
                m        = mean(temp);
                mCurrent = mean(gui.distributions(indD(jj),indV(ii)));
                shift    = mCurrent-m;
                temp.set('meanShift',shift)
                gui.distributions(indD(jj),indV(ii)) = temp;
            end
        end
    else
        for ii = length(indV)    
            for jj = 1:length(indD)
                gui.distributions(indD(jj),indV(ii)) = copy(gui.loaded);
            end
        end
    end

    % Update table contents
    gui.addToHistory();
    gui.updateGUI();
    
end

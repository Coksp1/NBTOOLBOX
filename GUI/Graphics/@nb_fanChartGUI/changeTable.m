function changeTable(gui,hObject,~)
% Syntax:
%
% changeTable(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;

    numPerc = size(plotterT.fanPercentiles,2);  
    if strcmpi(gui.type,'dataset')
        if isempty(hObject)
            nFans = gui.fanDataset.numberOfDatasets/2;
        else
            nFans = get(hObject,'value');
        end
    else
        nFans = size(gui.fanVariables,2)/2; 
    end
        
    perc = plotterT.fanPercentiles(:);
    if numPerc > nFans
        perc    = perc(1:nFans);
    elseif nFans > numPerc
        if strcmpi(gui.type,'variable') || ~isempty(hObject)
            perc = 0.1:0.9/nFans:0.9;
            perc = perc(:);
        end
    end
    perc = cellstr(num2str(perc));
    
    % Assign changes to the percentile table
    set(gui.table,'data',perc)
    

end

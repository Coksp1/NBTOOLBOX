function editCallback(gui,~,~)
% Syntax:
%
% editCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Cell coordinates
    sel = gui.selectedCells;
    if isempty(sel)
        return 
    end
    
    dist = gui.distributions(sel(:,1),sel(:,2));
    if numel(dist) ~= 1
        nb_errorWindow('Cannot edit more then one distribution.')
        return
    end
    
    % Edit current distribution with GUI tool
    distOld = copy(dist);
    distGUI = nb_distributionGUI(gui, [dist,distOld],'editable',[true,false]);
    addlistener(distGUI, 'done', @updateDistribution);

    function updateDistribution(hObject, ~)
       gui.distributions(sel(:,1),sel(:,2)) = hObject.distribution(1);
       gui.addToHistory();
       gui.updateGUI();
    end
    
end


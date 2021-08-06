function selectDistributionCallback(gui, ~, ~)
% Syntax:
%
% selectDistributionCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    distributionGUI = nb_distributionGUI(gui, gui.distribution);
    addlistener(distributionGUI, 'done', @(varargin) updateDistribution(gui, distributionGUI));
end

function updateDistribution(gui, distributionGUI)
    gui.distribution = distributionGUI.distribution;
end

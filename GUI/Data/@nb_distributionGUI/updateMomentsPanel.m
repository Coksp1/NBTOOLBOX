function updateMomentsPanel(gui)  
% Syntax:
%
% updateMomentsPanel(gui) 
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    set(gui.meanText, 'string', gui.currentDistribution.mean);
    set(gui.medianText, 'string', gui.currentDistribution.median);
    set(gui.modeText, 'string', gui.currentDistribution.mode);
    set(gui.varianceText, 'string', gui.currentDistribution.variance);
    set(gui.stdText, 'string', gui.currentDistribution.std);
    set(gui.skewnessText, 'string', gui.currentDistribution.skewness);
    set(gui.kurtosisText, 'string', gui.currentDistribution.kurtosis);
    
end

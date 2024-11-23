function addAllLegends(gui,~,~)
% Syntax:
%
% addAllLegends(gui,hObject,event)
%
% Description:
%
% Part of DAG. Add all (remaining) legends to the lookupmatrix (i.e. 
% the table)
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    legendTexts = gui.plotter.legendText(2:2:end);
    legendTexts = setdiff(legendTexts, {''});
    gui.addKeys(legendTexts);
    
end

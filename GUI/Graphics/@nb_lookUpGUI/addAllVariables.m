function addAllVariables(gui,~,~)
% Syntax:
%
% addAllVariables(gui,hObject,event)
%
% Description:
%
% Part of DAG. Add all (remaining) variables to the lookupmatrix (i.e. 
% the table)
% 
% Written by Kenneth Sæterhagen Paulsen
 
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    allVariables = gui.plotter.getPlottedVariables(true);
    gui.addKeys(allVariables);
    
end

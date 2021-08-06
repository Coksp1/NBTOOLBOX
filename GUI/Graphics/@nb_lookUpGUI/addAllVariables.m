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
% Written by Kenneth S�terhagen Paulsen
 
% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    allVariables = gui.plotter.getPlottedVariables(true);
    gui.addKeys(allVariables);
    
end

function export(gui,~,~)
% Syntax:
%
% export(gui,hObject,event)
%
% Description:
%
% Part of DAG. Open up the export dialog window
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if isempty(gui.package.graphs)
        nb_errorWindow('It is not possible to export a empty package.')
        return
    end
    
    nb_exportPackageGUI(gui.parent,gui.package);

end

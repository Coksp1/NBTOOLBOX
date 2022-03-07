function export(gui,~,~)
% Syntax:
%
% export(gui,hObject,event)
%
% Description:
%
% Part of DAG. Open up the export dialog window
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if strcmpi(gui.type,'advanced')
        nb_exportGraphGUI(gui.plotterAdv);
    else
        nb_exportGraphGUI(gui.plotter);
    end

end

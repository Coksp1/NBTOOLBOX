function copy(gui,hObject,~)
% Syntax:
%
% copy(gui,hObject,event)
%
% Description:
%
% Part of DAG. Copy graph object locally
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if strcmpi(gui.type,'advanced')
        if size(gui.plotterAdv.plotter,2) > 1
            index                   = get(hObject,'userData');
            gui.parent.copiedObject = gui.plotterAdv.plotter(index).copy;
        else
            gui.parent.copiedObject = gui.plotterAdv.copy;
        end
    else
        gui.parent.copiedObject = gui.plotter.copy;
    end
    
end

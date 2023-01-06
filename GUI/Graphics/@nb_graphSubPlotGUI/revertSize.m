function revertSize(gui,~,~)
% Syntax:
%
% revertSize(gui,hObject,event)
%
% Description:
%
% Part of DAG. Revert the graph window to its default size. I.e. how the
% figure is printed.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    monitor = nb_getCurrentMonitor();
    matFig  = gui.figureHandle.figureHandle;
    posF    = get(matFig,'position');
    set(matFig,'position',[posF(1)   posF(2)  186.4   41.3846])
    oldUnits = get(matFig,'units');
    set(matFig,'units','pixels');
    nb_moveCenter(matFig,monitor);
    set(matFig,'units',oldUnits);
    
end

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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    matFig = gui.figureHandle.figureHandle;
    posF   = get(matFig,'position');
    set(matFig,'position',[posF(1)   posF(2)  186.4   41.3846]);
    
end

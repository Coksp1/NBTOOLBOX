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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    matFig = gui.figureHandle.figureHandle;
    posF   = get(matFig,'position');
    set(matFig,'units','characters');
    if strcmpi(gui.type,'advanced')
        set(matFig,'position',[posF(1)   posF(2)  220   48.3846])
    else
        set(matFig,'position',[posF(1)   posF(2)  186.4   41.3846])
    end
    
end

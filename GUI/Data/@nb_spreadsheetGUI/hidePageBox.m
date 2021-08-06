function hidePageBox(gui,~,~,type)
% Syntax:
%
% hidePageBox(gui,hObject,event,type)
%
% Description:
%
% Part of DAG. Function called by the contextmenu on the pagebox
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4 
        type = 'hide';
    end
    
    text = findobj(gui.figureHandle,'style','text');
    if ~strcmpi(type,'show')
        set(gui.pageBox,'visible','off');
        set(gui.numObsBox,'visible','off');
        set(text,'visible','off');
        set(gui.table,'position',[0 0 1 1]);
    else
        set(gui.pageBox,'visible','on');
        set(gui.numObsBox,'visible','on');
        set(text,'visible','on');
        set(gui.table,'position',[0 0.05 1 0.95]);
    end
    
    showMenu = findobj(gui.figureHandle,'label','Show information bar');
    
    if strcmpi(get(gui.pageBox,'visible'),'on')
        set(showMenu,'visible','off');
    else
        set(showMenu,'visible','on');
    end
    
end



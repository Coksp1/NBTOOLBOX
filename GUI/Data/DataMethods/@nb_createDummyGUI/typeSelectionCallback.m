function typeSelectionCallback(gui,~,~)
% Syntax:
%
% typeSelectionCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    index = get(gui.pop1,'value');
    switch index
        
        case 1
            set(gui.varDummyPanel,'visible','off');
            set(gui.timeDummyPanel,'visible','on');
            set(gui.seasonalDummyPanel,'visible','off');
        case 2
            set(gui.timeDummyPanel,'visible','off');
            set(gui.varDummyPanel,'visible','on');
            set(gui.seasonalDummyPanel,'visible','off');
        case 3 
            set(gui.timeDummyPanel,'visible','off');
            set(gui.varDummyPanel,'visible','off');
            set(gui.seasonalDummyPanel,'visible','on');
    end
    
end

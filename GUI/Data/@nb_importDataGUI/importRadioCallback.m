function importRadioCallback(gui,~,~)
% Syntax:
%
% importRadioCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Callback for radiobuttons in advanced panel
%
% Written by Eyo I. Herstad and Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isequal(get(gui.customSpec,'value'),0)
        set(gui.dateSelectBox,'enable','off');
        set(gui.transposeButton,'enable','off');
        set(gui.advSheetSelectBox,'enable','off');
        set(gui.varSelectBox,'enable','off');
        set(gui.dataSelectBox,'enable','off');
        set(gui.nameBox,'enable','off');
    else
        set(gui.dateSelectBox,'enable','on');
        set(gui.transposeButton,'enable','on');
        set(gui.advSheetSelectBox,'enable','on');
        set(gui.varSelectBox,'enable','on');
        set(gui.dataSelectBox,'enable','on');
        set(gui.nameBox,'enable','on');
    end

end


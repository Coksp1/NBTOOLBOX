function setToEnglish(gui,~,~)
% Syntax:
%
% setToEnglish(gui,hObject,event)
%
% Description:
%
% Part of DAG. Switch to english
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if strcmpi(gui.type,'advanced')
        for ii = 1:size(gui.plotterAdv.plotter,2)
            gui.plotterAdv.plotter(ii).language = 'english';
            graph(gui.plotterAdv.plotter(ii));
        end
    else
        gui.plotter.language = 'english';
        graph(gui.plotter);
    end
    
    fObj = findobj(gui.languageMenu,'Label','English');
    set(fObj,'checked','on');
    
    fObj = findobj(gui.languageMenu,'Label','Norwegian');
    set(fObj,'checked','off');
    
end

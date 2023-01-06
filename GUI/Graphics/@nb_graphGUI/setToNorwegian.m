function setToNorwegian(gui,~,~)
% Syntax:
%
% setToNorwegian(gui,hObject,event)
%
% Description:
%
% Part of DAG. Switch to norwegian.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if strcmpi(gui.type,'advanced')
        for ii = 1:size(gui.plotterAdv.plotter,2)
            gui.plotterAdv.plotter(ii).language = 'norwegian';
            graph(gui.plotterAdv.plotter(ii));
        end
    else
        gui.plotter.language = 'norwegian';
        graph(gui.plotter);
    end
    
    fObj = findobj(gui.languageMenu,'Label','English');
    set(fObj,'checked','off');
    
    fObj = findobj(gui.languageMenu,'Label','Norwegian');
    set(fObj,'checked','on');
    
end

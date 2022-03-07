function nb_makeFiguresDisappear(~,~)
% Syntax:
%
% nb_makeFiguresDisappear(hObject,event)
%
% Description:
%
% Callback function to make the all figures that are visible not visible.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    figs = findobj('type','figure');
    ind  = get(figs,'visible');
    ind  = strcmpi(ind,'on');
    figs = figs(ind); % Only disable the uicontrol object which are visible
    set(figs,'visible','off');
    for ii = 1:length(figs)
        setappdata(figs(ii), 'disappeared', 'yes');
    end
    drawnow();
    
end

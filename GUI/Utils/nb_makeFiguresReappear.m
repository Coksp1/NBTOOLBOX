function nb_makeFiguresReappear(~,~)
% Syntax:
%
% nb_makeFiguresReappear(hObject,event)
%
% Description:
%
% Callback function to make the all figures that where turn of by 
% nb_makeFiguresDisappear visible again.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    figs  = findobj('type','figure');
    check = cell(1,length(figs)); 
    for ii = 1:length(figs)
        check{ii} = getappdata(figs(ii), 'disappeared');
        rmappdata(figs(ii),'disappeared');
    end
    ind  = strcmpi(check,'yes');
    figs = figs(ind);
    set(figs,'visible','on');
    
end

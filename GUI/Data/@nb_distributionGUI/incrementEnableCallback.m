function incrementEnableCallback(gui,src, ~)
% Syntax:
%
% incrementEnableCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    switch lower(get(src, 'checked'))
        case 'on'
            gui.set('incrementMode', 'off');
        case 'off'
            gui.set('incrementMode', 'on');
    end
    
end

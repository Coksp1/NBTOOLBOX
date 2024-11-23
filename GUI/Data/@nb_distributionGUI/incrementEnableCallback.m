function incrementEnableCallback(gui,src, ~)
% Syntax:
%
% incrementEnableCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    switch lower(get(src, 'checked'))
        case 'on'
            gui.set('incrementMode', 'off');
        case 'off'
            gui.set('incrementMode', 'on');
    end
    
end

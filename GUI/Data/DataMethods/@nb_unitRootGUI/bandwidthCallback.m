function bandwidthCallback(gui,~,~)
% Syntax:
%
% bandwidthCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Switches between automatic and manual bandwidth selection
% 
% Written by Eyo Herstad

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get components
    methodSelectBox    = gui.bandwidthComponents.methodSelectBox;
    userSelectBtn      = gui.bandwidthComponents.userSelectBtn;
    bandwidthSelectBox = gui.bandwidthComponents.bandwidthSelectBox;

    % Switch avalible boxes in the GUI
    if isequal(get(userSelectBtn,'value'),1)
        set(methodSelectBox,'enable','off');
        set(bandwidthSelectBox,'enable','on');
    else
        set(methodSelectBox,'enable','on');
        set(bandwidthSelectBox,'enable','off');
    end
    
end


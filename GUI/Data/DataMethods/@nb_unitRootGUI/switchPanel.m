function switchPanel(gui,hObject,~)
% Syntax:
%
% switchPanel(gui,hObject,event)
%
% Description:
%
% Part of DAG. Switches panels when the type of test is changed.
% 
% Written by Eyo Herstad

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get type
    string = get(hObject,'string');
    index  = get(hObject,'value');
    type   = string{index};

    % Get panels
    levelDiffPanel = gui.unitRootPanels.levelDiffPanel;
    interceptPanel = gui.unitRootPanels.interceptPanel;
    lagLengthPanel = gui.unitRootPanels.lagLengthPanel;
    spectralPanel  = gui.unitRootPanels.spectralPanel;
    bandwidthPanel = gui.unitRootPanels.bandwidthPanel;
    switch type
        case 'Augmented Dickey-Fuller'
            set(levelDiffPanel,'visible','on');
            set(interceptPanel,'visible','on');
            set(lagLengthPanel,'visible','on');
            set(spectralPanel,'visible','off');
            set(bandwidthPanel,'visible','off');

        case 'Phillips-Perron'
            set(levelDiffPanel,'visible','on');
            set(interceptPanel,'visible','on');
            set(lagLengthPanel,'visible','off');
            set(spectralPanel,'visible','on');
            set(bandwidthPanel,'visible','on');

        case 'Kwiatkowski-Phillips-Schmidt-Shin'
            set(levelDiffPanel,'visible','on');
            set(interceptPanel,'visible','on');
            set(lagLengthPanel,'visible','off');
            set(spectralPanel,'visible','on');
            set(bandwidthPanel,'visible','on');
    end

end

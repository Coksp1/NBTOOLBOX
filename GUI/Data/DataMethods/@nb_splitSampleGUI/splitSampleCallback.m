function splitSampleCallback(gui,~,~,window)
% Syntax:
%
% splitSampleCallback(gui,hObject,event,window)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get and test arguments
    subsampleLength = str2double(get(gui.subsampleLengthBox,'string'));
    if ~nb_iswholenumber(subsampleLength)
        nb_errorWindow('Please type an integer')
        return
    end
    
    % Call function
    try
        gui.data = gui.data.splitSample(subsampleLength);
    catch Err
        nb_errorWindow(Err.message);
        return
    end
    
    % Finish
    close(window);
    notify(gui,'methodFinished');
end

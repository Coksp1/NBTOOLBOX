function setCandleWidth(gui,hObject,~)
% Syntax:
%
% setCandleWidth(gui,hObject,event)
%
% Description:
%
% Part of DAG. Change the candle width callback
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    string = get(hObject,'string');
    num    = str2double(string);
    if isnan(num)
        nb_errorWindow('The candle width must be given as a number.')
        return
    end

    % Assign graph object
    gui.plotter.set('candleWidth',num);
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');
    
end

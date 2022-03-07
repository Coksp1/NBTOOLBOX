function setFigureNameCallback(gui,~,~)
% Syntax:
%
% setFigureNameCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterA = gui.plotter;

    % Norwegian
    strNor = get(gui.editBox1,'string');
    plotterA.figureNameNor = strNor;
    
    % English
    strEng = get(gui.editBox2,'string');
    plotterA.figureNameEng = strEng;

    % Notify listeners
    notify(gui,'changedGraph');
    
    % Close window
    close(gui.figureHandle)

end

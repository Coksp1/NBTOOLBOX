function printFigure(gui,~,~)
% Syntax:
%
% printFigure(gui,hObject,event)
%
% Description:
%
% Part of DAG. Open up a print figure dialog window
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    warning('off','MATLAB:print:CustomResizeFcnInPrint')
    matFig = gui.figureHandle.figureHandle;
    set(matFig,'PaperOrientation','landscape',...
               'PaperPositionMode','auto');
    printdlg(matFig);
    
end

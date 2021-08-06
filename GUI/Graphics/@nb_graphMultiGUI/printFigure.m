function printFigure(gui,~,~)
% Syntax:
%
% printFigure(gui,hObject,event)
%
% Description:
%
% Part of DAG. Open up a print figure dialog window
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    warning('off','MATLAB:print:CustomResizeFcnInPrint')
    matFig = gui.figureHandle.figureHandle;
    set(matFig,'PaperOrientation','landscape',...
               'PaperPositionMode','auto');
    printdlg(matFig);
    
end

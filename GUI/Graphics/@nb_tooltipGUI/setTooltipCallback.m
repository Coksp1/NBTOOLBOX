function setTooltipCallback(gui,~,~)
% Syntax:
%
% setTooltipCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterA = gui.plotter;
    plotter  = gui.plotter.plotter;

    % Norwegian
    oldNor = plotterA.tooltipNor;
    strNor = get(gui.editBox1,'string');
    plotterA.set('tooltipNor' ,cellstr(strNor));
    
    % English
    oldEng = plotterA.tooltipEng;
    strEng = get(gui.editBox2,'string');
    plotterA.set('tooltipEng' ,cellstr(strEng));

    % Wrapping  
    oldW  = plotterA.footerWrapping;
    wrap  = nb_getUIControlValue(gui.tooltipWrapping,'logical');
    plotterA.set('tooltipWrapping',wrap);
    
    % Update the graph object
    try
        plotter.graph();
    catch Err
        plotterA.set('tooltipNor' ,oldNor);
        plotterA.set('tooltipEng' ,oldEng);
        plotterA.set('tooltipWrapping' ,oldW);
        plotter.graph();
        nb_errorWindow('Error while interpreting the figure title:: ', Err);
        return
    end
    
    % Notify listeners
    notify(gui,'changedGraph');

end

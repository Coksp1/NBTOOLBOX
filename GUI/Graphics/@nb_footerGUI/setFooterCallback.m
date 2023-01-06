function setFooterCallback(gui,~,~)
% Syntax:
%
% setFooterCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    plotterA = gui.plotter;
    if strcmpi(gui.type,'excel') 
        
        plotterA.plotter(plotterA.currentGraph).excelFooterNor = cellstr(get(gui.editBox1,'string'));
        plotterA.plotter(plotterA.currentGraph).excelFooterEng = cellstr(get(gui.editBox2,'string'));
        
    else
    
        plotter = gui.plotter.plotter;
        
        % Norwegian
        oldNor = plotterA.footerNor;
        strNor = get(gui.editBox1,'string');
        plotterA.set('footerNor' ,cellstr(strNor));

        % English
        oldEng = plotterA.footerEng;
        strEng = get(gui.editBox2,'string');
        plotterA.set('footerEng' ,cellstr(strEng));

        % Placement and wrapping
        oldP  = plotterA.footerPlacement;
        place = nb_getSelectedFromPop(gui.popupmenu);
        oldW  = plotterA.footerWrapping;
        wrap  = nb_getUIControlValue(gui.footerWrapping,'logical');
        plotterA.set('footerPlacement',place,'footerWrapping',wrap);

        % Update the graph object
        try
            plotter.graph();
        catch Err
            plotterA.set('footerNor' ,oldNor);
            plotterA.set('footerEng' ,oldEng);
            plotterA.set('footerPlacement' ,oldP);
            plotterA.set('footerWrapping' ,oldW);
            plotter.graph();
            nb_errorWindow('Error while interpreting the footer:: ', Err);
            return
        end
        
    end

    % Notify listeners
    notify(gui,'changedGraph');

end

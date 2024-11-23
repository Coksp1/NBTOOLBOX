function setFigureTitleCallback(gui,~,~)
% Syntax:
%
% setFigureTitleCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotterA = gui.plotter;
    if strcmpi(gui.type,'excel')
        
        plotterA.plotter(plotterA.currentGraph).excelTitleNor = cellstr(get(gui.editBox1,'string'));
        plotterA.plotter(plotterA.currentGraph).excelTitleEng = cellstr(get(gui.editBox2,'string'));   
        
    else
        
        plotter  = gui.plotter.plotter;

        % Norwegian
        oldNor = plotterA.figureTitleNor;
        strNor = get(gui.editBox1,'string');
        plotterA.set('figureTitleNor' ,cellstr(strNor));

        % English
        oldEng = plotterA.figureTitleEng;
        strEng = get(gui.editBox2,'string');
        plotterA.set('figureTitleEng' ,cellstr(strEng));

        % Placement and wrapping
        oldP  = plotterA.figureTitlePlacement;
        place = nb_getSelectedFromPop(gui.popupmenu);
        oldW  = plotterA.footerWrapping;
        wrap  = nb_getUIControlValue(gui.figureTitleWrapping,'logical');
        plotterA.set('figureTitlePlacement',place,'figureTitleWrapping',wrap);

        % Update the graph object
        try
            plotter.graph();
        catch Err
            plotterA.set('figureTitleNor' ,oldNor);
            plotterA.set('figureTitleEng' ,oldEng);
            plotterA.set('figureTitlePlacement' ,oldP);
            plotterA.set('figureTitleWrapping' ,oldW);
            plotter.graph();
            nb_errorWindow('Error while interpreting the figure title:: ', Err);
            return
        end
        
    end

    % Notify listeners
    notify(gui,'changedGraph');

end

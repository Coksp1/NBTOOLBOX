function saveToSession(gui,~,~)
% Syntax:
%
% saveToSession(gui,~,~)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
    
    s      = gui.infoStruct;
    graphs = gui.parent.graphs;
    fields = fieldnames(s);
    
    for ii = 1:length(fields)
        
        % Get current graph
        advGraph = fields{ii};
        
        % Getting information from struct and saving to graph
        graphs.(advGraph).figureNameNor  = s.(advGraph).figureNameNor;
        graphs.(advGraph).figureNameEng  = s.(advGraph).figureNameEng;
        graphs.(advGraph).figureTitleNor = s.(advGraph).figureTitleNor;
        graphs.(advGraph).figureTitleEng = s.(advGraph).figureTitleEng;
        graphs.(advGraph).footerNor      = s.(advGraph).footerNor;
        graphs.(advGraph).footerEng      = s.(advGraph).footerEng;
        graphs.(advGraph).tooltipNor     = s.(advGraph).tooltipNor;
        graphs.(advGraph).tooltipEng     = s.(advGraph).tooltipEng;  
        
        % Setting the underlying objects as well
        figTitleObjectNor        = get(graphs.(advGraph).plotter(1),'figTitleObjectNor');
        figTitleObjectNor.string = char(s.(advGraph).figureTitleNor);
        figTitleObjectEng        = get(graphs.(advGraph).plotter(1),'figTitleObjectEng');
        figTitleObjectEng.string = char(s.(advGraph).figureTitleEng);
        footerObjectNor          = get(graphs.(advGraph).plotter(1),'footerObjectNor');
        footerObjectNor.string   = char(s.(advGraph).footerNor);
        footerObjectEng          = get(graphs.(advGraph).plotter(1),'footerObjectEng');
        footerObjectEng.string   = char(s.(advGraph).footerEng);
        graphs.(advGraph).plotter(1).setSpecial('figTitleObjectNor',figTitleObjectNor);
        graphs.(advGraph).plotter(1).setSpecial('figTitleObjectEng',figTitleObjectEng);
        graphs.(advGraph).plotter(1).setSpecial('footerObjectNor',footerObjectNor);
        graphs.(advGraph).plotter(1).setSpecial('footerObjectEng',footerObjectEng);
        
        % Check is panel and implement changes
        if ~(s.(advGraph).panel)
            % Regular graph
            graphs.(advGraph).plotter.excelTitleNor  = s.(advGraph).excelTitleNor;
            graphs.(advGraph).plotter.excelTitleEng  = s.(advGraph).excelTitleEng;
            graphs.(advGraph).plotter.excelFooterNor = s.(advGraph).excelFooterNor;
            graphs.(advGraph).plotter.excelFooterEng = s.(advGraph).excelFooterEng;
        else
            % Panel 1
            graphs.(advGraph).plotter(1).excelTitleNor  = s.(advGraph).excelTitleNor_1;
            graphs.(advGraph).plotter(1).excelTitleEng  = s.(advGraph).excelTitleEng_1;
            graphs.(advGraph).plotter(1).excelFooterNor = s.(advGraph).excelFooterNor_1;
            graphs.(advGraph).plotter(1).excelFooterEng = s.(advGraph).excelFooterEng_1;
            % Panel 2
            graphs.(advGraph).plotter(2).excelTitleNor  = s.(advGraph).excelTitleNor_2;
            graphs.(advGraph).plotter(2).excelTitleEng  = s.(advGraph).excelTitleEng_2;
            graphs.(advGraph).plotter(2).excelFooterNor = s.(advGraph).excelFooterNor_2;
            graphs.(advGraph).plotter(2).excelFooterEng = s.(advGraph).excelFooterEng_2;
        end
    
    end
    
    % Sync information with graph package
    syncPackage(gui.parent,gui.name);
    
    % This adds asterix to parent to indicate unsaved changes
    gui.parent.graphs = graphs;
    
    % Inform user
    nb_infoWindow('The information was successfully saved to the session and to packages.')

end

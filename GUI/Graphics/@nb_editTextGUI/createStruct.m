function infoStruct = createStruct(parent,graphNames)
% Syntax:
%
% infoStruct = createStruct(parent,graphNames)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    graphs = parent.graphs;
    s      = struct();
    
    for ii = 1:length(graphNames)
        
        % Create field in struct for graph
        advGraph           = graphNames{ii};
        s.(graphNames{ii}) = struct();
        
        % Filling struct with text information
        s.(advGraph).figureNameNor  = graphs.(advGraph).figureNameNor;
        s.(advGraph).figureNameEng  = graphs.(advGraph).figureNameEng;
        s.(advGraph).figureTitleNor = graphs.(advGraph).figureTitleNor;
        s.(advGraph).figureTitleEng = graphs.(advGraph).figureTitleEng;
        s.(advGraph).footerNor      = graphs.(advGraph).footerNor;
        s.(advGraph).footerEng      = graphs.(advGraph).footerEng;
        s.(advGraph).tooltipNor     = graphs.(advGraph).tooltipNor;
        s.(advGraph).tooltipEng     = graphs.(advGraph).tooltipEng;
        
        % Panel as bool
        if size(graphs.(advGraph).plotter,2) > 1
            s.(advGraph).panel = true;
        else
            s.(advGraph).panel = false;
        end
        
        if ~s.(advGraph).panel
            
            s.(advGraph).excelTitleNor  = graphs.(advGraph).plotter.excelTitleNor;
            s.(advGraph).excelTitleEng  = graphs.(advGraph).plotter.excelTitleEng;
            s.(advGraph).excelFooterNor = graphs.(advGraph).plotter.excelFooterNor;
            s.(advGraph).excelFooterEng = graphs.(advGraph).plotter.excelFooterEng;
        else
            s.(advGraph).excelTitleNor_1  = graphs.(advGraph).plotter(1).excelTitleNor;
            s.(advGraph).excelTitleEng_1  = graphs.(advGraph).plotter(1).excelTitleEng;
            s.(advGraph).excelFooterNor_1 = graphs.(advGraph).plotter(1).excelFooterNor;
            s.(advGraph).excelFooterEng_1 = graphs.(advGraph).plotter(1).excelFooterEng;
            
            s.(advGraph).excelTitleNor_2  = graphs.(advGraph).plotter(2).excelTitleNor;
            s.(advGraph).excelTitleEng_2  = graphs.(advGraph).plotter(2).excelTitleEng;
            s.(advGraph).excelFooterNor_2 = graphs.(advGraph).plotter(2).excelFooterNor;
            s.(advGraph).excelFooterEng_2 = graphs.(advGraph).plotter(2).excelFooterEng;
        end
            
    end
    
    infoStruct = s;
end


function importExcelChangeLog(obj,excelFile)
% Syntax:
%
% exportExcelChangeLog(obj,excelFile)
%
% Description:
%
% Reads the Excel file and updates the written information in the graph
% package based on the Excel file. Note that the file must be structured
% such that it is identical to a file created by exportExcelChangeLog.
%
% Input:
%
% - obj       : An object of class nb_graph_package.
%
% - excelFile : 1 x n char. The Excel file with the information.
%
% Examples:
%
% obj.importExcelChangeLog('myExcelFile.xls');
%
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    data = nb_xlsread(excelFile);
    
    % Getting data
    numbers      = data(2:end,1);
    identifiers  = data(2:end,2);
    norNames     = data(2:end,3);
    engNames     = data(2:end,4);
    norTitles    = data(2:end,5);
    engTitles    = data(2:end,6);
    norFooters   = data(2:end,7);
    engFooters   = data(2:end,8);
    norXLTitles  = data(2:end,9);
    engXLTitles  = data(2:end,10);
    norXLFooters = data(2:end,11);
    engXLFooters = data(2:end,12);
    norTooltips  = data(2:end,13);
    engTooltips  = data(2:end,14);
    %titleWrap    = data(2:end,15); trenger vi disse da titler og footers
    %footerWrap   = data(2:end,16); %leses inn som cells?
    
    graphs    = unique(numbers);
    numGraphs = length(graphs);
    
    for ii = 1:numGraphs
        
        graphNum = graphs{ii};
        match    = strcmpi(graphNum,numbers);
        rowIndex = find(match);
        
        iden     = identifiers{rowIndex(1)};
        graphIdx = strcmpi(iden,obj.identifiers);
        graphObj = obj.graphs{graphIdx}; 
                   
        % Implementing changes
        graphObj.figureNameNor  = norNames{rowIndex(1)};
        graphObj.figureNameEng  = engNames{rowIndex(1)};
        graphObj.figureTitleNor = fixLineBreaks(norTitles{rowIndex(1)});
        graphObj.figureTitleEng = fixLineBreaks(engTitles{rowIndex(1)});
        graphObj.footerNor      = fixLineBreaks(norFooters{rowIndex(1)});
        graphObj.footerEng      = fixLineBreaks(engFooters{rowIndex(1)});
        graphObj.tooltipNor     = fixLineBreaks(norTooltips{rowIndex(1)});
        graphObj.tooltipEng     = fixLineBreaks(engTooltips{rowIndex(1)});

        if length(rowIndex) == 1 % No subfigures
            graphObj.plotter.excelTitleNor  = fixLineBreaks(norXLTitles{rowIndex});
            graphObj.plotter.excelTitleEng  = fixLineBreaks(engXLTitles{rowIndex});
            graphObj.plotter.excelFooterNor = fixLineBreaks(norXLFooters{rowIndex});
            graphObj.plotter.excelFooterEng = fixLineBreaks(engXLFooters{rowIndex});
        else
            for gg = 1:size(graphObj.plotter,2)
                graphObj.plotter(gg).title          = fixLineBreaks(norTitles{rowIndex(gg + 1)});
                graphObj.plotter(gg).excelTitleNor  = fixLineBreaks(norXLTitles{rowIndex(gg + 1)});
                graphObj.plotter(gg).excelTitleEng  = fixLineBreaks(engXLTitles{rowIndex(gg + 1)});
                graphObj.plotter(gg).excelFooterNor = fixLineBreaks(norXLFooters{rowIndex(gg + 1)});
                graphObj.plotter(gg).excelFooterEng = fixLineBreaks(engXLFooters{rowIndex(gg + 1)});
            end
        end      
 
    end
    
    nb_infoWindow('The graph package was successfully updated.')
        
end

function out = fixLineBreaks(in)
    if isnan(in)
        out = {};
    else
        out = regexp(in,'\n','split')';
    end
end

function exportExcelChangeLog(obj,saveName,packageName)
% Syntax:
%
% exportExcelChangeLog(obj,saveName,packageName)
%
% Description:
%
% Exports the written information in a graph package to an Excel file. 
% The exported file will contain titles, footers, and excel footers with 
% all DAG formatting visible.
% Changes can be made to the exported file. This file can be imported to
% DAG and all changes will take place.
%
% Input:
%
% - obj         : An object of class nb_graph_package.
%
% - saveName    : The name of the Excel file to write.
%
% - packageName : The name of the graph package.
%
% Examples:
%
% obj.writeText('MyGraphPackage');
%
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
   
    if nargin < 3
        packageName = 'Graph Package';
        if nargin < 2
            saveName = ['GraphPackageChangeLog', '_', nb_clock()];
        end
    end
   
    try
        numOfGraphs   = size(obj.graphs,2);
        graphsToPrint = obj.graphs;

        number = nb_numbering(obj.start - 1,obj.chapter,'english',obj.bigLetter);

        numOfGraphsTot = 0;
        for ii = 1:numOfGraphs
            if isa(graphsToPrint{ii},'nb_graph_adv')
                numGraphsOne   = size(graphsToPrint{ii}.plotter,2);
                if numGraphsOne > 1
                    numOfGraphsTot = numOfGraphsTot + numGraphsOne + 1;
                else
                    numOfGraphsTot = numOfGraphsTot + 1;
                end
            else
                numGraphsOne    = length(graphsToPrint{ii}.graphObjects);
                numOfGraphsTot  = numOfGraphsTot + numGraphsOne;
            end
        end

    catch Err
        nb_errorWindow('Could not write Excel file.', Err)
    end

    try

        % Get the numbered figure titles and the footers of the graphs
        counter         = 1;
        figureTitlesN   = repmat({''},[1,numOfGraphsTot]);
        figureTitlesE   = figureTitlesN;
        figureNamesN    = figureTitlesN;
        figureNamesE    = figureTitlesN;
        footersN        = figureTitlesN;
        footersE        = figureTitlesN;
        saveNames       = figureTitlesN;
        titleWrap       = figureTitlesN;
        footerWrap      = figureTitlesN;
        excelTitlesN    = figureTitlesN;
        excelTitlesE    = figureTitlesE;
        excelFootersN   = figureTitlesN;
        excelFootersE   = figureTitlesE;
        tooltipsN       = figureTitlesE;
        tooltipsE       = figureTitlesE;
        kk              = 1;
        numbering       = cell(1,numOfGraphsTot);

        for ii = 1:numOfGraphs

            graphObj = graphsToPrint{ii};
            iden     = obj.identifiers{ii};
            if isa(graphObj,'nb_graph_adv')

                [numStr,counter]  = nb_getFigureNumbering(graphObj,number,counter);
                figureNamesN{kk}  = graphObj.figureNameNor;
                figureNamesE{kk}  = graphObj.figureNameEng;
                figureTitlesN{kk} = graphObj.figureTitleNor;
                figureTitlesE{kk} = graphObj.figureTitleEng;
                footersN{kk}      = graphObj.footerNor;
                footersE{kk}      = graphObj.footerEng;
                tooltipsN{kk}     = graphObj.tooltipNor;
                tooltipsE{kk}     = graphObj.tooltipEng;
                if size(graphObj.plotter,2 ) == 1
                    excelTitlesN{kk}  = graphObj.plotter.excelTitleNor;  
                    excelTitlesE{kk}  = graphObj.plotter.excelTitleEng;
                    excelFootersN{kk} = graphObj.plotter.excelFooterNor;  
                    excelFootersE{kk} = graphObj.plotter.excelFooterEng;
                end
                titleWrap{kk}     = graphObj.figureTitleWrapping;
                footerWrap{kk}    = graphObj.footerWrapping;
                saveNames{kk}     = iden;
                numbering{kk}     = numStr;
                kk                = kk + 1;
                if size(graphObj.plotter,2) > 1
                    % If we are dealing with 1x2 panel in a nb_graph_adv object
                    % we may have some subtitles of each graph
                    for gg = 1:size(graphObj.plotter,2)
                        figureTitlesN{kk} = graphObj.plotter(gg).title;
                        figureTitlesE{kk} = graphObj.plotter(gg).title;
                        excelTitlesN{kk}  = graphObj.plotter(gg).excelTitleNor; 
                        excelTitlesE{kk}  = graphObj.plotter(gg).excelTitleEng; 
                        excelFootersN{kk} = graphObj.plotter(gg).excelFooterNor; 
                        excelFootersE{kk} = graphObj.plotter(gg).excelFooterEng; 
                        saveNames{kk}     = [iden,'_subtitle_' int2str(gg)];
                        numbering{kk}     = numStr;
                        kk                = kk + 1;
                    end
                end

            else
                nb_errorWindow('This method is not supported for graph packages that includes a graph panel.')
            end

        end

        % Column headers
        headers = {'Number (do not edit)',...
                   'Identifier (do not edit)',...
                   'Nor Figure Name',...
                   'Eng Figure Name',...
                   'Norwegian Title',...
                   'English Title',...
                   'Norwegian Footer',...
                   'English Footer',...
                   'Nor Excel Title',...
                   'Eng Excel Title',...
                   'Nor Excel Footer',...
                   'Eng Excel Footer',...
                   'Nor Tooltip',...
                   'Eng Tooltip',...
                   'Title Wrapping (do not edit)',...
                   'Footer Wrapping (do not edit)'};      

        % Format data
        numbering    = numbering';
        saveNames    = saveNames';
        figureNamesN = figureNamesN';
        figureNamesE = figureNamesE';

        figureTitlesN = formatCell(figureTitlesN);
        figureTitlesE = formatCell(figureTitlesE);
        footersN      = formatCell(footersN);
        footersE      = formatCell(footersE);
        excelTitlesN  = formatCell(excelTitlesN);
        excelTitlesE  = formatCell(excelTitlesE);
        excelFootersN = formatCell(excelFootersN);
        excelFootersE = formatCell(excelFootersE);
        tooltipsN     = formatCell(tooltipsN);
        tooltipsE     = formatCell(tooltipsE);

        titleWrap  = titleWrap';
        footerWrap = footerWrap';

        % Concatenate cell array to be written to Excel
        c = [headers;... % First row contain the titles
            numbering,...
            saveNames,...
            figureNamesN,...
            figureNamesE,...
            figureTitlesN,...
            figureTitlesE,...
            footersN,...
            footersE,...
            excelTitlesN,...
            excelTitlesE,...
            excelFootersN,...
            excelFootersE,...
            tooltipsN,...
            tooltipsE,...
            titleWrap,...
            footerWrap];

        nb_xlswrite(saveName,c,packageName,1);
        
     catch Err
        nb_errorWindow(['Could not write Excel file. Failed for the graph ' iden '.'], Err)
    end
end 

function newCell = formatCell(oldCell)
% Formats text such that newline character and sprintf can be used to 
% preserve line breaks. Converts the old cell array to a new one with 
% same length, but with only 1x1 cells.    
    c = cell(length(oldCell),1);
    for ii = 1:length(oldCell)
        prop = oldCell{ii};
        if ~isempty(prop)
            [s1,~] = size(prop);

            for jj = 1:s1
                prop{jj,:} = strrep(prop{jj,:},'%','%%');
                prop{jj,:} = strrep(prop{jj,:},'\','\\');
                if jj < s1
                    prop{jj,:} = [prop{jj,:},'\n']; 
                end
            end
            c{ii} = sprintf([prop{:}]);
        end
    end
    newCell = c;
end

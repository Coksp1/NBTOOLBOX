function writeText(obj,folder,language,index,includeFigureNumber,singleFolder,lazyWriting,skipConfirmation)
% Syntax:
%
% writeText(obj,folder,language,index,includeFigureNumber)
%
% Description:
%
% Write text of graphs to .txt files. One for the figure title and one
% for the footer for each graph separately. Each graph will be save with
% the name of the assign identifier. See the nb_graph_package.add for more
% on the identifiers.
%
% Input:
%
% - obj      : An object of class nb_graph_package
%
% - folder   : The folder to save the text of the graphs to.
%
% - language : The language as a string, 'english' or
%              {'norsk'}. Will also be appended the save names.
%
% - index    : Either a 1 x numGraphs logical or empty. Set the matching
%              element of a graph to false to skip writing the text of
%              that graph. Default is empty, i.e. to write the text of
%              all graphs of the package.
%
% - includeFigureNumber : Include figure number in file names. Default
%                         is false.
%
% - singleFolder : Save files to a single folder or make two subfolders
%                  and save text to one and extended text to the other.
%                  Default is true.
%
% - lazyWriting : Write only the text files that have changed (cannot find
%                 the file or the file content is identical to what is 
%                 about to be written). The files that are written are reported in 
%                 a separate window. Default is false
%
% - skipConfirmation : Skip the confirmation window and go straight to
%                      writing or not. Default is false.
%
% Examples:
%
% obj.writeText('test', 'english');
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    if nargin < 8
        skipConfirmation = false;
        if nargin < 7
            lazyWriting = false;
            if nargin < 6
                singleFolder = true;
                if nargin < 5
                    includeFigureNumber = false;
                    if nargin < 4
                        index = [];
                        if nargin < 3
                            language = '';
                        end
                    end
                end
            end
        end
    end
    
    if skipConfirmation
       if isempty(folder)
           error([mfilename ':: The input <folder> cannot be empty if you want to skip the confirmation window.'])
       end
       yes([],[],obj,folder,language,index,includeFigureNumber,singleFolder,lazyWriting);
    else
        if ~isempty(folder)
            if exist(folder,'dir')
                nb_confirmWindow(['Are you sure you want to save the TXT files to ',...
                    'the folder ' folder],@no,@(h,e)yes(h,e,obj,folder,language,index,includeFigureNumber,singleFolder,lazyWriting));
            else
                succ = mkdir(folder);
                if ~succ
                    nb_errorWindow(['Could not make the folder ' folder '.'])
                else
                    yes([],[],obj,folder,language,index,includeFigureNumber,singleFolder,lazyWriting);
                end
            end
        else
            error([mfilename ':: The input folder cannot be empty.'])
        end
    end
        


end

function no(h,~)
    delete(get(h,'parent'));
end

function yes(h,~,obj,folder,language,index,includeFigureNumber,singleFolder,lazyWriting)
    
    if not(strcmp(folder(end),'\'))
        folder = [folder,'\'];
    end
    
    % Create subfolders
    if ~singleFolder
        
        textfolder     = [folder,'Title and source'];
        extendedfolder = [folder,'Tooltip'];
        
        % Check if folders are present already
        if ~exist(textfolder,'dir')
            succ = mkdir(textfolder);
            if ~succ
                nb_errorWindow(['Could not make the folder ' textfolder '.'])
            end
        end
        if ~exist(extendedfolder,'dir')
            succ = mkdir(extendedfolder);
            if ~succ
                nb_errorWindow(['Could not make the folder ' extendedfolder '.'])
            end
        end
        
    end

    try
        
        % Delete confirmation window
        delete(get(h,'parent'));

        % Write a copy of each graph object
        numOfGraphs   = size(obj.graphs,2);
        graphsToPrint = obj.graphs;
        if isempty(index)
            index = true(1,numOfGraphs);
        else
            if ~islogical(index)
                error([mfilename ':: The index input must be logical.'])
            end
            if size(index,2) ~= numOfGraphs
                error([mfilename ':: The index input must be logical with size 1x' int2str(numOfGraphs) '.'])
            end
        end

        number = nb_numbering(obj.start - 1,obj.chapter,language,obj.bigLetter);
        if strcmpi(language,'english')
            figTitleProperty    = 'figureTitleEng';
            footerProperty      = 'footerEng';
            excelFooterProperty = 'excelFooterEng';
            tooltipProperty     = 'tooltipEng';
        else
            figTitleProperty    = 'figureTitleNor';
            footerProperty      = 'footerNor';
            excelFooterProperty = 'excelFooterNor';
            tooltipProperty     = 'tooltipNor';
        end

        numOfGraphsTot = 0;
        indexC         = cell(1,numOfGraphs);
        for ii = 1:numOfGraphs
            if isa(graphsToPrint{ii},'nb_graph_adv')
                numGraphsOne   = size(graphsToPrint{ii}.plotter,2);
                if numGraphsOne > 1
                    numOfGraphsTot = numOfGraphsTot + numGraphsOne + 1;
                    indexC{ii}     = index(1,ii*ones(1,numGraphsOne + 1));
                else
                    numOfGraphsTot = numOfGraphsTot + 1;
                    indexC{ii}     = index(ii);
                end
            else
                numGraphsOne    = length(graphsToPrint{ii}.graphObjects);
                numOfGraphsTot  = numOfGraphsTot + numGraphsOne;
                indexC{ii}      = index(1,ii*ones(1,numGraphsOne));
            end
        end
        indexExcel = index;
        index      = [indexC{:}];

    catch Err
        nb_errorWindow('Could not write TXTs.', Err)
    end
    
    try
        
        % Get the numbered figure titles and the footers of the graphs
        counter        = 1;
        figureTitles   = repmat({''},[1,numOfGraphsTot]);
        footers        = figureTitles;
        saveNames      = figureTitles;
        excelFooters   = repmat({''},[1,numOfGraphs]);
        tooltips       = excelFooters;
        excelSaveNames = excelFooters;
        kk             = 1; % Counter for numOfGraphsTot
        numbering      = cell(1,numOfGraphsTot);
        numberingExcel = excelFooters;
        for ii = 1:numOfGraphs

            graphObj = graphsToPrint{ii};
            iden     = obj.identifiers{ii};
            if isa(graphObj,'nb_graph_adv')

                oldLanguage = graphObj.plotter(1).language;
                for jj = 1:length(graphObj.plotter)
                    graphObj.plotter(jj).language = language;
                end
                [numStr,counter]  = nb_getFigureNumbering(graphObj,number,counter);
                figureTitle       = graphObj.(figTitleProperty);
                try
                    figureTitle = nb_localVariables(graphObj.localVariables,figureTitle);
                catch Err
                    nb_errorWindow(['Could not interpret the local variable ',...
                        'of the figure title "' fix(figureTitle) '" of the graph ' iden], Err);
                end
                try
                    figureTitle = nb_localFunction(graphObj,figureTitle,true);
                catch Err
                    nb_errorWindow(['Could not interpret the local function ',...
                        'of the figure title "' fix(figureTitle) '" of the graph ' iden], Err)
                end
                if isempty(figureTitle)
                    figureTitle{1} = numStr;
                else
                    figureTitle{1} = [numStr ' ' figureTitle{1}];
                end
                figureTitles{kk} = figureTitle;
                footers{kk}      = graphObj.(footerProperty);
                try
                    footers{kk} = nb_localVariables(graphObj.localVariables,footers{kk});
                catch Err
                    nb_errorWindow(['Could not interpret the local variable ',...
                        'of the footer "' fix(footers{kk}) '" of the graph ' iden], Err)
                end
                try
                    footers{kk} = nb_localFunction(graphObj,footers{kk},true);
                catch Err
                    nb_errorWindow(['Could not interpret the local function ',...
                        'of the footer "' fix(footers{kk}) '" of the graph ' iden], Err)
                end
                tooltips{ii} = graphObj.(tooltipProperty);
                try
                    tooltips{ii} = nb_localVariables(graphObj.localVariables,tooltips{ii});
                catch Err
                    nb_errorWindow(['Could not interpret the local variable ',...
                        'of the tooltip "' fix(tooltips{ii}) '" of the graph ' iden], Err)
                end
                try
                    tooltips{ii} = nb_localFunction(graphObj,tooltips{ii},true);
                catch Err
                    nb_errorWindow(['Could not interpret the local function ',...
                        'of the tooltip "' fix(tooltips{ii}) '" of the graph ' iden], Err)
                end
                saveNames{kk}    = iden;
                numbering{kk}    = numStr;
                kk               = kk + 1;
                if size(graphObj.plotter,2) > 1
                    % If we are dealing with 1x2 panel in a nb_graph_adv object
                    % we may have some subtitles of each graph
                    for gg = 1:size(graphObj.plotter,2)
                        figureTitles{kk} = graphObj.plotter(gg).title;
                        try
                            figureTitles{kk} = nb_localVariables(graphObj.localVariables,figureTitles{kk});
                        catch Err
                            nb_errorWindow(['Could not interpret the local variable ',...
                                'of the figure title "' fix(figureTitles{kk}) '" of the graph ',...
                                iden,'_subtitle_' int2str(gg)], Err)
                        end
                        try
                            figureTitles{kk} = nb_localFunction(graphObj,figureTitles{kk},true);
                        catch Err
                            nb_errorWindow(['Could not interpret the local function ',...
                                'of the figure title "' fix(figureTitles{kk}) '" of the graph ',...
                                iden,'_subtitle_' int2str(gg)], Err)
                        end
                        saveNames{kk} = [iden,'_subtitle_' int2str(gg)];
                        numbering{kk} = numStr;
                        kk            = kk + 1;
                    end
                end

                % Excel footers
                for gg = 1:size(graphObj.plotter,2)
                    excelFootersOne = graphObj.plotter(gg).(excelFooterProperty);
                    try
                        excelFootersOne = nb_localVariables(graphObj.plotter(gg).localVariables,excelFootersOne);
                    catch Err
                        nb_errorWindow(['Could not interpret the local variable ',...
                            'of the excel footer "' fix(excelFootersOne) '" of the graph ',...
                            iden,'_subtitle_' int2str(gg)], Err)
                    end
                    try
                        excelFootersOne = nb_localFunction(graphObj.plotter(gg),excelFootersOne,true);
                    catch Err
                        nb_errorWindow(['Could not interpret the local function ',...
                            'of the excel footer "' fix(excelFootersOne) '" of the graph ',...
                            iden,'_subtitle_' int2str(gg)], Err)
                    end
                    if gg == 1
                        excelFooters{ii} = excelFootersOne;
                    else
                        excelFooters{ii} = [excelFooters{ii}; {''}; excelFootersOne];
                    end
                end
                numberingExcel{ii} = numStr;
                for jj = 1:length(graphObj.plotter)
                    graphObj.plotter(jj).language = oldLanguage;
                end

            else

                for gg = 1:length(graphObj.graphObjects)

                    plotter = graphObj.graphObjects{gg};
                    if isa(plotter,'nb_graph_adv')

                        oldLanguage = plotter.plotter(1).language;
                        for jj = 1:length(plotter.plotter)
                            plotter.plotter(jj).language = language;
                        end
                        
                        [numStr,counter]  = nb_getFigureNumbering(plotter,number,counter);
                        figureTitle       = plotter.(figTitleProperty);
                        try
                            figureTitle = nb_localVariables(plotter.localVariables,figureTitle);
                        catch Err
                            nb_errorWindow(['Could not interpret the local variable ',...
                                'of the figure title "' fix(figureTitle) '" of the graph ',...
                                iden,'_subtitle_' int2str(gg)], Err)
                        end
                        try
                            figureTitle = nb_localFunction(plotter,figureTitle,true);
                        catch Err
                            nb_errorWindow(['Could not interpret the local function ',...
                                'of the figure title "' fix(figureTitle) '" of the graph ',...
                                iden,'_subtitle_' int2str(gg)], Err)
                        end
                        if isempty(figureTitle)
                            figureTitle{1} = numStr;
                        else
                            figureTitle{1} = [numStr ' ' figureTitle{1}];
                        end
                        figureTitles{kk} = figureTitle;
                        footers{kk}      = plotter.(footerProperty);
                        try
                            footers{kk} = nb_localVariables(plotter.localVariables,footers{kk});
                        catch Err
                            nb_errorWindow(['Could not interpret the local variable ',...
                                'of the footer "' fix(footers{kk}) '" of the graph ',...
                                iden,'_subtitle_' int2str(gg)], Err)
                        end
                        try
                            footers{kk} = nb_localFunction(plotter,footers{kk},true);
                        catch Err
                            nb_errorWindow(['Could not interpret the local function ',...
                                'of the footer "' fix(footers{kk}) '" of the graph ',...
                                iden,'_subtitle_' int2str(gg)], Err)
                        end
                        tooltips{ii} = plotter.(tooltipProperty);
                        try
                            tooltips{ii} = nb_localVariables(plotter.localVariables,tooltips{ii});
                        catch Err
                            nb_errorWindow(['Could not interpret the local variable ',...
                                'of the tooltip "' fix(tooltips{ii}) '" of the graph ',...
                                iden,'_subtitle_' int2str(gg)], Err)
                        end
                        try
                            tooltips{ii} = nb_localFunction(plotter,tooltips{ii},true);
                        catch Err
                            nb_errorWindow(['Could not interpret the local function ',...
                                'of the tooltip "' fix(tooltips{ii}) '" of the graph ',...
                                iden,'_subtitle_' int2str(gg)], Err)
                        end
                        
                        excelFootersOne = plotter.plotter.(excelFooterProperty);
                        try
                            excelFootersOne = nb_localVariables(plotter.plotter.localVariables,excelFootersOne);
                        catch Err
                            nb_errorWindow(['Could not interpret the local variable ',...
                                'of the excel footer "' fix(excelFootersOne) '" of the graph ',...
                                iden,'_subtitle_' int2str(gg)], Err)
                        end
                        try
                            excelFootersOne = nb_localFunction(plotter.plotter,excelFootersOne,true);
                        catch Err
                            nb_errorWindow(['Could not interpret the local function ',...
                                'of the excel footer "' fix(excelFootersOne) '" of the graph ',...
                                iden,'_subtitle_' int2str(gg)], Err)
                        end
                        if gg == 1
                            numberingExcel{ii} = numStr;
                            excelFooters{ii}   = excelFootersOne;
                        else
                            excelFooters{ii} = [excelFooters{ii}; {''}; excelFootersOne];
                        end
                        for jj = 1:length(plotter.plotter)
                            plotter.plotter(jj).language = oldLanguage;
                        end

                    else
                        
                        oldLanguage      = plotter.language;
                        plotter.language = language;
                        
                        number.plus(1);
                        numStr  = char(number);
                        counter = 1;
                        title   = plotter.title;
                        title   = nb_localVariables(plotter.localVariables,title);
                        title   = nb_localFunction(plotter,title);
                        if isempty(title)
                            title = numStr;
                        else
                            if ischar(title)
                                title = char([numStr ' ' title(1,:)],title(2:end,:));
                            else % is a cell
                                title{1} = [numStr ' ' title{1}];
                            end
                        end
                        figureTitles{kk} = title;
                        
                        excelFootersOne = plotter.(excelFooterProperty);
                        excelFootersOne = nb_localVariables(plotter.localVariables,excelFootersOne);
                        excelFootersOne = nb_localFunction(plotter,excelFootersOne);
                        if gg == 1
                            numberingExcel{ii} = numStr;
                            excelFooters{ii}   = excelFootersOne;
                        else
                            excelFooters{ii} = [excelFooters{ii}; {''}; excelFootersOne];
                        end
                        plotter.language = oldLanguage;
                        
                    end
                    
                    if gg == 1
                        saveNames{kk} = iden;
                    else
                        saveNames{kk} = [iden,'_' int2str(gg)];
                    end
                    numbering{kk} = numStr;
                    kk            = kk + 1;

                end

            end
            excelSaveNames{ii} = iden;

        end
        
    catch Err
        nb_errorWindow(['Could not write TXTs. Failed for the graph ' iden '.'], Err)
    end

    try
    
        % Replace . and whitespace with underscore
        numbering = regexprep(numbering,'[\s\.]','_');
        
        if ~singleFolder
            folder = [textfolder,'\'];
        end
        
        if lazyWriting
            textUpdate     = cell(numOfGraphsTot,1);
            commentsUpdate = cell(numOfGraphsTot,1);
        end

        % Write the text to files
        for kk = 1:numOfGraphsTot
            if index(kk)
                if ~isempty(figureTitles{kk}) || ~isempty(footers{kk})
                    if includeFigureNumber
                        iden     = [numbering{kk} '_' saveNames{kk} '_' language '.txt'];
                        saveNFig = [folder, iden];
                    else
                        iden     = [saveNames{kk} '_' language '.txt'];
                        saveNFig = [folder, iden];
                    end
                    figTitle = convert2text(figureTitles{kk});
                    footer   = convert2text(footers{kk});
                    if isempty(figureTitles{kk})
                        both = footer;
                    elseif isempty(footers{kk})
                        both = figTitle;
                    else
                        both = [figTitle;{''};footer];
                    end
                    
                    if lazyWriting
                        if ~nb_compareCell2TXT(both,saveNFig)
                            % Identical file already does not exist, write
                            % and save information.
                            textUpdate{kk} = iden;
                            nb_cellstr2file(both,saveNFig,true);
                        end
                    else
                        nb_cellstr2file(both,saveNFig,true);
                    end
                    
                end
            end
        end
        
        if ~singleFolder
            folder = [extendedfolder,'\'];
        end

        % Write excel footers to files
        for ii = 1:numOfGraphs
            if indexExcel(ii)
                if ~isempty(excelFooters{ii}) || ~isempty(tooltips{ii})
                    if includeFigureNumber
                        iden     = [numberingExcel{ii} '_' excelSaveNames{ii} '_extended_' language '.txt'];
                        saveNFig = [folder, iden];
                    else
                        iden     = [excelSaveNames{ii} '_extended_' language '.txt'];
                        saveNFig = [folder, iden];
                    end
                    
                    if ~isempty(tooltips{ii})
                        extdText = convert2text(tooltips{ii});
                    else
                        extdText = convert2text(excelFooters{ii});
                    end
                    if lazyWriting
                        if ~nb_compareCell2TXT(extdText,saveNFig)
                            % Identical file already does not exist, write
                            % and save information.
                            commentsUpdate{kk} = iden;
                            nb_cellstr2file(extdText,saveNFig,true);
                        end
                    else
                        nb_cellstr2file(extdText,saveNFig,true);
                    end
                end
            end
        end
        
        % Inform user about what files were written
        if lazyWriting
            if strcmpi(language,'norsk')
                lang = 'Norwegian';
            else
                lang = 'English';
            end
            textInd = cellfun(@isempty,textUpdate);
            if all(textInd) 
                nb_infoWindow(['No ' lang ' text files were updated.'],'Text Updates',false,'off',[],'normal')
            elseif ~any(textInd)
                nb_infoWindow(['All ' lang ' text files were updated.'],'Text Updates',false,'off',[],'normal')
            else
                textUpdate(cellfun(@isempty,textUpdate)) = [];
                nb_infoWindow(textUpdate,[ lang ' Text Updates'],true,'on',[],'normal')
            end
            
            commentsInd = cellfun(@isempty,commentsUpdate);
            if all(commentsInd)
                nb_infoWindow(['No ' lang ' technical comment files were updated.'],'Technical Comments Updates',false,'off',[],'normal')
            elseif ~any(textInd)
                nb_infoWindow(['All ' lang ' technical comment files were updated.'],'Technical Comments Updates',false,'off',[],'normal')
            else
                commentsUpdate(cellfun(@isempty,commentsUpdate)) = [];
                nb_infoWindow(commentsUpdate,[lang ' Technical Comments Updates'],true,'on',[],'normal')
            end
        end

    catch Err
        nb_errorWindow('Could not write TXTs. Most likely due to a file that is tried to be written to is open.', Err)
    end

end

%==========================================================================
function out = convert2text(in)
    if iscell(in)
        out = in;
        for ii = 1:length(in)
            out{ii} = convert2textSub(in{ii});
        end  
    else
        out = convert2textSub(in);
    end
end

%==========================================================================
function out = convert2textSub(in)
    out = interpretSuperScript(in);
    out = removeBold(out);
    out = removeTextBackSlashes(out);
    out = removeCurlyBrackets(out);
end

%==========================================================================
function out = interpretSuperScript(in)
    [s,e] = regexp(in,'\^\{[^\^]+\}','start','end');
    if isempty(s)
        out = in;
        return
    end
    out = cell(1,size(s,2));
    e   = [0,e];
    for ii = 1:size(s,2)
        out{ii} = [in(e(ii)+1:s(ii)-1),'#',in(s(ii)+2:e(ii+1)-1)];
    end
    out = horzcat(out{:},in(e(ii+1)+1:end));
end

%==========================================================================
function out = removeBold(in)
    out = strrep(in,'\bf','');
end

%==========================================================================
function out = removeTextBackSlashes(in)
    out = strrep(in,'//','');
end

%==========================================================================
function out = removeCurlyBrackets(in)
    s   = strrep(in,'{','');
    out = strrep(s,'}','');
end

%==========================================================================
function out = fix(in)
    if iscellstr(in)
        out = nb_cellstr2String(in, ' ');
    else
        out = in;
    end
end

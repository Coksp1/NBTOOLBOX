function saveData(obj,saveName,language,firstPageName,firstPageName2,roundoff,excelStyle)
% Syntax:
% 
% saveData(obj,saveName,language)
% saveData(obj,saveName,language,firstPageName,firstPageName2,roundoff,...
%         excelStyle)
%          
% 
% Description:
% 
% Save the data behind the graphs of the graph package to excel.
% 
% Input:
% 
% - obj             : An object of class nb_graph_package
% 
% - saveName        : The excel file name as a string
% 
% - language        : The language as a string. On of the 
%                     following:
%
%                     > 'english' : The data are written to a excel
%                                   spreadsheet with only english
%                                   text.
%                     > 'norsk'   : The data are written to a excel
%                                   spreadsheet with only norwegian
%                                   text.
%                     > 'both'    : The data are written to a excell
%                                   spreadsheet with both norwegian
%                                   and english text.
% 
% - firstPageName   : Sets the heading on the index page of the  
%                     excel spreadsheet. When the language input is 
%                     'norwegian' or 'both' this will be the  
%                     heading of the norwegian index page. Must be  
%                     given as a string or as an cellstr. A cellstr 
%                     will give a multilined heading. E.g.  
%                     'Index page' or {'Index page','second line'}.
% 
% - firstPageName2  : Sets the heading on the index page of the  
%                     excel spreadsheet. When the language input is 
%                     'english' or 'both' this will be the heading  
%                     of the english index page. Must be given as a 
%                     string or as an cellstr. A cellstr will give 
%                     a multilined heading. E.g. 'Index page' or 
%                     {'Index page','second line'}.
% 
% - roundoff        : Give 1 if you want to round off to 2 
%                     decimals, 0 otherwise. Default is obj.roundoff.
%     
% Examples:
%
% package.saveData('test','both',{'Rapport',...
%                  'med noe nyttig'},...
%                  {'A report',...
%                   'with something useful'},...
%                   1);
% 
% Written by Per Bjarne Bye and Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

% Some useful Excel functions:
% White  : 16777215
% Gray   : 15790320
% Gray   : 14277081 (for borders)
% Orange : 4626167
% Blue   : -4030384

% Align left horizontally  : -4131
% Align right horizontally : -4152
% Align center vertically  : -4108

% Borders:
% Left edge of the range  : 7
% Right edge of the range : 10
% Top of the range        : 8
% Bottom of the range     : 9

% Vertical borders for all the cells in the range except borders on the
% outside of the range : 11
% Horizontal borders for all cells in the range except borders on the
% outside of the range : 12

    if nargin < 7
        excelStyle = obj.excelStyle;
        if nargin < 6
            roundoff = obj.roundoff;
            if nargin < 5 
                firstPageName2 = obj.firstPageNameEng;
                if nargin < 4
                    firstPageName = obj.firstPageNameNor;
                end  
            end
        end
    end
    
    if any(cellfun('isclass',obj.graphs,'nb_graph_subplot'))
        error([mfilename ':: The saveData method is not yet supported when panels are included in the package. '...
                         'Please contact NB Toolbox developers if needed.'])
    end
    
    if ~any(strcmpi(language,{'engelsk','english','both','norsk','norwegian'}))
         error([mfilename ':: Language not supported. Choose between "engelsk","english","both","norsk","norwegian"'])  
    end
    
    % Open up the waitbar window
    numberOfGraphs = 0;
    for ii = 1:size(obj.graphs,2)
        % Some graphs may be panels
        numberOfGraphs = numberOfGraphs + size(obj.graphs{ii}.plotter,2);
    end
    nSteps = 1;
    h      = nb_waitbar([],'Save Data of Graph Package',size(obj.graphs,2) + numberOfGraphs*2 + nSteps);
    h.text = 'Initializing...'; 
    
    % Get names on the first page of the excel output
    if isempty(firstPageName2)
        firstPageName2 = cellstr(saveName);
    else
        if ischar(firstPageName)
            firstPageName = cellstr(firstPageName);
        end
    end
    
    if isempty(firstPageName)
        firstPageName = cellstr(saveName);
    else
        if ischar(firstPageName2)
            firstPageName2 = cellstr(firstPageName2);
        end
    end
    
    % Delete excel sheet if it exists
    warning('off','MATLAB:xlswrite:AddSheet');
    if exist([saveName '.xlsx'],'file') == 2
        dos(['del ' saveName '.xlsx']);
    end
    
    % Create the struct which will be used to load variables into sub
    % functions
    %--------------------------------------------------------------
    S                = struct();
    S.obj            = obj;
    S.saveName       = saveName;
    S.language       = language;
    S.firstPageName  = firstPageName;
    S.firstPageName2 = firstPageName2;
    S.roundoff       = roundoff;
    S.excelStyle     = excelStyle;
    S.numberOfGraphs = numberOfGraphs;
    
    % Create struct with info on each graph
    graphSettings(1,numberOfGraphs) = struct(...
        'bold',[],...
        'cellData',{{}},...
        'colWidth',[],...
        'dataEnd',[],...
        'fcstInd',[],...
        'figCellE',{{}},...
        'figCellN',{{}},...
        'figureTitleEng',{{}},...
        'figureTitleNor',{{}},...
        'fooCellE',{{}},...
        'fooCellN',{{}},...
        'footerEng',{{}},...
        'footerNor',{{}},...
        'graphData',{{}},...
        'identifier','',...
        'notPublished',false,...
        'numberOfColumns',[],...
        'numberOfRows',[],...
        'numberOfVars',[],...
        'number','',...
        'rows',[],...
        'sheetNames','',...
        'start',[],...
        'superscript',[],...
        'type',[]... 
    );
    
    % Create the index page
    %--------------------------------------------------------------
    if any(strcmpi(language, 'both'))
        createIndexPage(S,graphSettings,'norsk');
        graphSettings = createIndexPage(S,graphSettings,'engelsk');
        S.numberingLanguage = 'english';
    else         
        graphSettings = createIndexPage(S,graphSettings,language);
        if any(strcmpi(language,{'engelsk','english'}))
            S.numberingLanguage = 'english';
        else
            S.numberingLanguage = 'norwegian';
        end
    end

    % Update the waitbar
    %--------------------------------------------------------------
    h.status = 1;
    h.text   = ['Get data; ' obj.identifiers{1} '...'];
    
    %--------------------------------------------------------------
    % Get the data for each figure
    %--------------------------------------------------------------
    index = 1;
    for ii = 1:size(obj.graphs,2)
        
        % Get the data...
        [graphSettings,index] = getDataOfAdvancedGraph(S,obj.graphs{ii},graphSettings,index);
        
        % Update the waitbar
        if ii < size(obj.graphs,2)
            h.status = 1 + ii;
            h.text   = ['Get data; ' obj.identifiers{ii+1} '...'];
        end
        
    end 
  
    % Write to excel
    %----------------------------------------------------------
    h.status   = h.status + 1;
    h.text     = ['Saving; ' graphSettings(1).identifier '...'];     
    sheetNames = repmat({''},[1,numberOfGraphs]);
    for ii = 1:numberOfGraphs
    
        try
            
            numStr = graphSettings(ii).number;
            if strcmpi(S.numberingLanguage,'english')
                numStr = strrep(numStr,'Chart','Data');
            else
                numStr = strrep(numStr,'Figur','Data');
            end
            found = find(strcmp(numStr,sheetNames),1);
            if ~isempty(found)
                numStr = [numStr '(2)']; %#ok<AGROW>
            end
            
            % Change sheet names if style is FSR
            if ii == 1
                Excel = nb_xlswrite([saveName '.xlsx'],graphSettings(ii).cellData,numStr,true);
            else
                nb_xlswrite([saveName '.xlsx'],graphSettings(ii).cellData,numStr,false,Excel);
            end
            sheetNames{ii} = numStr;
            
        catch Err
            
            if any(strcmpi(language,{'english','engelsk'}))
                figName = graph.figureNameEng;
            else
                figName = graph.figureNameNor;
            end
            
            try %#ok<TRYNC>
                Excel.ActiveWorkbook.Save;
                Excel.ActiveWorkbook.Close;
                Excel.Quit;
                Excel.delete; 
            end
            error([mfilename ':: Error while writing the data to excel (i.e. using xlswrite) for ',...
                'the figure ' figName '. MATLAB error :: ' Err.message])
            
        end

        % Update the waitbar
        %--------------------------------------------------------------
        try
            if ii < numberOfGraphs
                h.status = h.status + 1;
                h.text   = ['Saving; ' graphSettings(ii+1).identifier '...'];
            end
        catch Err
            Excel.ActiveWorkbook.Save;
            Excel.ActiveWorkbook.Close;
            Excel.Quit;
            Excel.delete;
            rethrow(Err);
        end

    end
    
    % Update the waitbar
    %--------------------------------------------------------------
    try
        h.status = h.status + 1;
        h.text   = 'Formatting; Excel sheet and index page...';
    catch Err
        Excel.ActiveWorkbook.Save;
        Excel.ActiveWorkbook.Close;
        Excel.Quit;
        Excel.delete;
        rethrow(Err);
    end
        
    %==============================================================
    % Format the excel spreadsheet
    %==============================================================
    try
        
        % First open Excel
        S.Sheets    = Excel.ActiveWorkBook.Sheets;
        sheet_names = nb_xlsGetSheets(Excel);
        if strcmpi(excelStyle,'fsr')
            sheet_names = strrep(sheet_names,'Data','Data ');
        end
        
        % Load in some required variables
        S.index_adjust = 0;
        S.sheetNames   = sheetNames;

        % Cycle through the sheets
        %----------------------------------------------------------
        kk        = 1;
        numSheets = length(sheet_names);
        for i = 1:numSheets
            
            % For the FSR style we want to start off with a white
            % background
            if strcmpi(S.excelStyle,'fsr')               
                current_sheet = get(S.Sheets, 'Item', (i-S.index_adjust));
                invoke(current_sheet, 'Activate');
                Activesheet = Excel.Activesheet;
                Activesheet.Cells.Interior.Color = 16777215;
            end

            switch sheet_names{i}

                case{'Sheet1','Sheet2','Sheet3'}

                    % Delete sheets
                    current_sheet = get(S.Sheets, 'Item', (i-S.index_adjust));
                    invoke(current_sheet, 'Delete')
                    S.index_adjust = S.index_adjust + 1;

                case {'Innhold','Index'}

                    formatIndexPage(S,Excel,i);
                    try
                        h.status = h.status + 1;
                        h.text   = ['Formatting; ' graphSettings(1).identifier '...'];
                    catch Err
                        Excel.ActiveWorkbook.Save;
                        Excel.ActiveWorkbook.Close;
                        Excel.Quit;
                        Excel.delete;
                        rethrow(Err);
                    end
                    
                otherwise
                    
                    switch graphSettings(kk).type
                        case 'ts'
                            Activesheet = formatTS(S,graphSettings(kk),Excel,i); 
                        case 'cell'
                            Activesheet = formatCell(S,graphSettings(kk),Excel,i); 
                        otherwise
                            Activesheet = formatDefault(S,graphSettings(kk),Excel,i);
                    end

                    % Interpret the superscript and bold text
                    %----------------------------------------
                    interpretCharType(Activesheet,graphSettings(kk).superscript,'Superscript');
                    interpretCharType(Activesheet,graphSettings(kk).bold,'Bold');
                    
                    % Update the waitbar
                    %-------------------
                    if i < numSheets
                        h.status = h.status + 1;
                        h.text   = ['Formatting;' graphSettings(kk+1).identifier '...'];
                    end
                    kk = kk + 1;
                
            end

        end

    catch Err
        % Close excel objects
        Excel.ActiveWorkbook.Save;
        Excel.ActiveWorkbook.Close;
        Excel.Quit;
        Excel.delete;
        rethrow(Err);
    end

    % Close excel objects
    Excel.ActiveWorkbook.Save;
    Excel.ActiveWorkbook.Close;
    Excel.Quit;
    Excel.delete;

end


%==================================================================
% SUB
%==================================================================

function graphSettings = createIndexPage(S,graphSettings,language)
% Create index page. 

    if any(strcmpi(language,{'norsk','norwegian'}))
        
        lang          = 'norsk';
        lang2         = 'Norwegian';
        id            = 'Innhold';
        figName       = 'figureNameNor';
        firstPageName = S.firstPageName;
        
    else
        
        lang          = 'english';
        lang2         = 'English';
        id            = 'Index';
        figName       = 'figureNameEng';
        firstPageName = S.firstPageName2;
        
    end
          
    try

        firstPage          = cell(S.numberOfGraphs + 6,2);
        firstPage{2,2}     = firstPageName{1};
        try firstPage{3,2} = firstPageName{2}; catch; end %#ok<CTCH>
        %firstPage{4,2} = date;
        if strcmpi(S.excelStyle,'mpr')
            firstPage{6,2}     = id;
        end
        num     = nb_numbering(S.obj.start - 1,S.obj.chapter,lang,S.obj.bigLetter);
        ss      = 7;
        counter = 1;
        kk      = 1;
        for ii = 1:size(S.obj.graphs,2)

            graph = S.obj.graphs{ii};
            if size(graph.plotter,2) > 1 % We have a 1x2 panel

                letterCurrent = graph.letter;
                graph.letter  = true;
                for jj = 1:size(graph.plotter,2)

                    % Number figures as Data 1.1a - 1.1b
                    [numStr,counter] = nb_getFigureNumbering(graph,num,counter);

                    % The more elaborated figure name
                    extra = graph.(figName);
                    extra = nb_localVariables(graph.localVariables,extra);

                    % Add the figure to the first page
                    firstPage{ss,2}              = [numStr,' ', extra];
                    graphSettings(kk).number     = numStr;
                    graphSettings(kk).identifier = S.obj.identifiers{ii};
                    ss = ss + 1;
                    kk = kk + 1;

                end
                graph.letter = letterCurrent;

            else

                [numStr,counter] = nb_getFigureNumbering(graph,num,counter);

                % The more elaborated figure name
                extra = graph.(figName);
                extra = nb_localVariables(graph.localVariables,extra);

                % Add the figure to the first page
                firstPage{ss,2}              = [numStr,' ', extra];
                graphSettings(kk).number     = numStr;
                graphSettings(kk).identifier = S.obj.identifiers{ii};

                ss = ss + 1;
                kk = kk + 1;

            end

        end

        xlswrite([S.saveName '.xlsx'], firstPage, id);

    catch Err
        error([mfilename ':: Something went wrong when creating the first page in ', lang2 ,'. For the figure ' graph.(figName)...
                         '. MATLAB error message:: ' Err.message])
    end
        
end

%==========================================================================
function [graphSettings,index] = getDataOfAdvancedGraph(S,graph,graphSettings,index)

    % Get the data of the graphs of the advanced graph
    for ii = 1:size(graph.plotter,2)

        % Get figure title and footer of advanced graph
        % Caution: May be overrun by graph later on!
        try
            % Get the figure title and footer
            graphSettings(index) = getTitleFooter(graphSettings(index),graph,graph.plotter(ii));
        catch Err
            if any(strcmpi(S.language,{'english','engelsk'}))
                figName = graph.figureNameEng;
            else
                figName = graph.figureNameNor;
            end
            error('nb_graph:LocalVariableError',[mfilename ':: Error when interpreting the local ',...
                'variables/local functions of the figure ' figName '. MATLAB error :: ' Err.message])
        end
        
        % Then we get all the data and other stuff from the graph
        graphSettings(index) = getDataOfGraph(S,graph,graphSettings(index),ii);
        index                = index + 1;
        
    end

end

%==========================================================================
function graphSettings = getDataOfGraph(S,graph,graphSettings,subIndex)

    % Remove unwanted variables from the written data
    %----------------------------------------------------------
    if isa(graph.plotter(subIndex),'nb_graph')

        % Get the data of the graph
        graphSettings.graphData = getData(graph.plotter(subIndex),S.obj.zeroLowerBound);
        graphSettings.graphData = removeVars(graph,graphSettings.graphData);

        % Here we must convert the data to a cell. We also
        % find the forecast date option needed for later
        % (only for time-series data)
        graphSettings = convertData2Cell(S,graphSettings,graph,subIndex);
        
        % Merge the footer and figure title with the cell data
        graphSettings = mergeTitleAndFooterWithData(S,graphSettings,graph,graph.plotter(subIndex));
        
        % Get superscript and bold index
        %----------------------------------------------------------
        [graphSettings.cellData,graphSettings.superscript] = getSuperIndex(graphSettings.cellData);
        [graphSettings.cellData,graphSettings.bold]        = getBoldIndex(graphSettings.cellData);
        
        % Store the number of columns and rows for later use.
        % Keep track of if last column is only used to hold 
        % 'Projections' string and no other data.
        %----------------------------------------------------------
        graphSettings.numberOfColumns = graphSettings.colWidth;
        graphSettings.numberOfVars    = checkLastColForData(graphSettings.numberOfColumns,graphSettings.cellData);
        graphSettings.numberOfRows    = size(graphSettings.cellData,1);
        
    else

        if any(strcmpi(S.language,{'english','engelsk'}))
            figName = graph.figureNameEng;
        else
            figName = graph.figureNameNor;
        end
        error([mfilename ':: The ''plotter'' property of the nb_graph_adv object is not a nb_graph object. (For the figure ' figName '.)'])

    end
      
end

%==========================================================================

function graphSettings = convertData2Cell(S,graphSettings,graph,subIndex)

    try

        if isempty(graphSettings.graphData)

            if isa(graphSettings.graphData,'nb_ts')
                graphSettings.type = 'ts';
            elseif isa(graphSettings.graphData,'nb_data')
                graphSettings.type = 'data';
            elseif isa(graphSettings.graphData,'nb_cs')
                graphSettings.type = 'cs';
            else
                graphSettings.type = 'cell';
            end
            graphSettings.cellData     = {'','','';'','Data publiseres ikke/data are not published',''};
            graphSettings.notPublished = true;

        else

            switch class(graphSettings.graphData)

                case 'nb_ts'

                    % Make it a cell 
                    %----------------------------------------------
                    graphSettings = convertToCell(S,graphSettings,graph);

                    % Find the forecast coloring index for the
                    % variables
                    %------------------------------------------
                    graphSettings = findForecastIndTS(S,graphSettings,graph);

                    % Set the type of the graph
                    %------------------------------------------
                    graphSettings.type  = 'ts';
                    graphSettings.start = 2;


                case 'nb_data'

                    % Make it a cell 
                    %----------------------------------------------
                    graphSettings = convertToCell(S,graphSettings,graph);

                    % Set the type of the graph
                    %------------------------------------------
                    graphSettings.type  = 'data';
                    graphSettings.start = 2;

                case 'nb_cs'

                    % Make it a cell and add two variable lines 
                    % and two type lines (We need to translate 
                    % to both English and Norwegian)
                    %------------------------------------------
                    graphSettings = convertToCell(S,graphSettings,graph);

                    % Find the forecast coloring index for the
                    % variables
                    %------------------------------------------
                    graphSettings = findForecastIndCS(S,graphSettings,graph);

                    % Look up the types of the given figure 
                    % data. Make it robust for multi-line 
                    % description of types
                    %----------------------------------------------
                    graphSettings = lookUpTypes(graphSettings,graph.plotter(subIndex),S.language);

                    % Set the type of the graph
                    %------------------------------------------
                    graphSettings.type  = 'cs';
                    graphSettings.start = 3;

            case 'nb_cell'

                    % Make it a cell
                    %------------------------------------------
                    graphSettings = convertToCell(S,graphSettings,graph);

                    % Look up all the elements of the given figure 
                    % data. Make it robust for multi-line description
                    % of types
                    %----------------------------------------------
                    graphSettings = lookUpElements(graphSettings,graph.plotter(subIndex),S.language);

                    % Set the type of the graph
                    %------------------------------------------
                    graphSettings.type  = 'cell';
                    graphSettings.start = 1;        

            end

            % Look up the variables of the given figure 
            % data
            %----------------------------------------------
            if ~strcmpi(graphSettings.type,'cell')
                graphSettings = lookUpVariables(graphSettings,graph.plotter(subIndex),S.language);
            end

        end

    catch Err

        if strcmpi(Err.identifier,'saveData:forecastDate')
            rethrow(Err)
        else
            if strcmpi(S.language,'english') || strcmpi(S.language,'engelsk')
                figName = graph.figureNameEng;
            else
                figName = graph.figureNameNor;
            end
            error([mfilename ':: Error while transforming the data of the graph to a cell for the figure ' figName '. MATLAB error :: ' Err.message])
        end

    end    

end

%==========================================================================
function graphSettings = mergeTitleAndFooterWithData(S,graphSettings,graph,plotter)

    try
            
        % Merge with the data
        %------------------------------------------------------
        sizeTemp = size(graphSettings.cellData);
        if sizeTemp(2) < 3
            colWidth               = 3;
            added                  = cell(sizeTemp(1),1);
            graphSettings.cellData = [graphSettings.cellData,added]; 
        else
            colWidth = sizeTemp(2);
        end
        graphSettings.colWidth = colWidth;

        % Correct the norwegian figure title
        %------------------------------------------------------
        if any(strcmpi(S.language,{'norsk','norwegian','both'}))
            graphSettings = correctTitle(S,graphSettings,'n');
        end

        % Correct the english figure title
        %------------------------------------------------------
        if any(strcmpi(S.language,{'engelsk','english','both'}))
            graphSettings = correctTitle(S,graphSettings,'e');
        end

        % Correct the norwegian footer
        %------------------------------------------------------
        if strcmpi(S.language,'both')
            graphSettings.rows = 2;
        else
            graphSettings.rows = 1;
        end
        if any(strcmpi(S.language,{'norsk','norwegian','both'}))
            graphSettings = correctFooter(S,graphSettings,graph,plotter,'n');
        end

        % Correct the english footer
        %------------------------------------------------------
        if any(strcmpi(S.language,{'engelsk','english','both'}))
            graphSettings = correctFooter(S,graphSettings,graph,plotter,'e');
        end

        % Add extra text to the cell
        %------------------------------------------------------
        extra = cell(2,colWidth);

        % If the style is MPR, we want an extra link to Projections
        if strcmpi(S.excelStyle,'mpr')
            extra{1,3} = 'Anslag/Projections';
        end

        switch lower(S.language)

            case 'both'
                
                if strcmpi(graphSettings.type,'ts') && strcmpi(S.excelStyle,'fsr')
                    % Add Dato/Date title if we are using FSR style
                    graphSettings.cellData{1,1} = 'Dato';
                    graphSettings.cellData{2,1} = 'Date';
                end
                extra{1,1}             = 'Innhold';
                extra{1,2}             = 'Index';
                graphSettings.cellData = [graphSettings.figCellN; graphSettings.fooCellN;...
                                          graphSettings.figCellE; graphSettings.fooCellE;...
                                          extra;graphSettings.cellData];

            case {'norsk','norwegian'}

                extra{1,1}             = 'Innhold';
                graphSettings.cellData = [graphSettings.figCellN; graphSettings.fooCellN;...
                                          extra; graphSettings.cellData];

            case {'english','engelsk'}

                extra{1,1}             = 'Index';
                graphSettings.cellData = [graphSettings.figCellE; graphSettings.fooCellE;...
                                          extra; graphSettings.cellData]; 
        end

    catch Err
        if any(strcmpi(S.language,{'english','engelsk'}))
            figName = graph.figureNameEng;
        else
            figName = graph.figureNameNor;
        end
        error([mfilename ':: Error while adding figure title and footer text to the cell written ',...
            'for the figure ' figName '. MATLAB error :: ' Err.message])
    end
        
end


%==========================================================================
function graphSettings = convertToCell(S,graphSettings,graph)
% Convert the data to a cell

    setRoundOff = graph.roundoff;
    if isempty(setRoundOff)
        setRoundOff = S.obj.roundoff;
    end
    cellData = graphSettings.graphData.asCellForMPRReport(setRoundOff);

    if strcmpi(S.language,'both') && any(strcmpi(class(graphSettings.graphData),{'nb_ts','nb_data'}))
        % Add two variable lines (We need to translate to both English and
        % Norwegian)
        cellData = [cellData(1,:); cellData];
    
    elseif strcmpi(S.language,'both') && strcmpi(class(graphSettings.graphData),'nb_cs')
       cellData = [cellData(1,:); cellData];
       cellData = [cellData(:,1), cellData];
    end
    graphSettings.cellData = cellData;
    
end

%==========================================================================
function graphSettings = findForecastIndTS(S,graphSettings,graph)
% Find the forecast coloring index for the variables of a time series

    graphSettings.dataEnd = size(graphSettings.cellData,1);
    try
        graphSettings.fcstInd = interpretForecastDate(graphSettings.graphData,graphSettings.cellData,...
                                    graph.forecastDate,graph.localVariables);
    catch Err
        if any(strcmpi(S.language,{'english','engelsk'}))
            figName = graph.figureNameEng;
        else
            figName = graph.figureNameNor;
        end
        error('saveData:forecastDate',[mfilename ':: Error while interpreting the forecastDate ',...
            'property of the figure ' figName '. MATLAB error message::' Err.message])
    end
    
end

%==========================================================================
function graphSettings = findForecastIndCS(S,graphSettings,graph)
% Find the forecast coloring index for the variables of a cross section

    graphSettings.dataEnd = size(graphSettings.cellData,2);
    try
        graphSettings.fcstInd = interpretForecastTypes(graphSettings.cellData,graph.forecastTypes);
    catch Err
        if any(strcmpi(S.language,{'english','engelsk'}))
            figName = graph.figureNameEng;
        else
            figName = graph.figureNameNor;
        end
        error('saveData:forecastDate',[mfilename ':: Error while interpreting the forecastDate property of the figure ' figName '. MATLAB error message::' Err.message])
    end
    
end

%==========================================================================
function graphSettings = getTitleFooter(graphSettings,graph,plotter)
% Get the correct title and save it in the struct

    if isemptyText(plotter.excelTitleEng)
        figTitE = graph.figureTitleEng;
    else
        figTitE = plotter.excelTitleEng;
    end
    if isemptyText(plotter.excelTitleNor)
        figTitN = graph.figureTitleNor;
    else
        figTitN = plotter.excelTitleNor;
    end    
    
    if isemptyText(graph.excelFooterEng)
        footerE = graph.footerEng;
    else
        footerE = graph.excelFooterEng;
    end
    if isemptyText(graph.excelFooterNor)
        footerN = graph.footerNor;
    else
        footerN = graph.excelFooterNor;
    end

    tempLanguage = plotter.language;
    if isstruct(graph.localVariables)

        plotter.language = 'english';
        figTitE = nb_localVariables(graph.localVariables,figTitE);
        figTitE = nb_localFunction(plotter,figTitE);
        footerE = nb_localVariables(graph.localVariables,footerE);
        footerE = nb_localFunction(plotter,footerE);

        plotter.language = 'norsk';
        figTitN = nb_localVariables(graph.localVariables,figTitN);
        figTitN = nb_localFunction(plotter,figTitN);
        footerN = nb_localVariables(graph.localVariables,footerN);
        footerN = nb_localFunction(plotter,footerN);
        
    end
    plotter.language = tempLanguage;
    
    graphSettings.figureTitleEng = figTitE;
    graphSettings.figureTitleNor = figTitN;
    graphSettings.footerEng      = footerE;
    graphSettings.footerNor      = footerN;
    
end

function ret = isemptyText(text)

    ret = false;
    if isempty(text)
        ret = true;
    elseif iscellstr(text)
        if length(text) == 1 && isempty(text{1})
            ret = true;
        end
    end
end

%==========================================================================
function graphSettings = correctTitle(S,graphSettings,lang)
% Corrects the title for inclusion in the Excel spreadsheet.
    
    number = graphSettings.number;
    if strcmpi(lang,'n')
        arr           = 'figCellN';
        figTitleField = 'figureTitleNor';
        if strcmpi(S.numberingLanguage,'english')
            number = strrep(number,'Chart','Figur');
        end
    else
        arr           = 'figCellE';
        figTitleField = 'figureTitleEng';
    end
    
    % Correct figure title
    figT = graphSettings.(figTitleField);
    figT = str2Excel(figT);
    figT = removeBold(figT);
    figT = removeTextBackSlashes(figT);
    
    % Add title header with figure number
    graphSettings.(arr)      = cell(1,graphSettings.colWidth);
    graphSettings.(arr){1,1} = [number,' ',figT];
    
end
%==========================================================================
function graphSettings = correctFooter(S,graphSettings,graph,plotter,lang)
% Corrects the footer for inclusion in the Excel spreadsheet.

    if strcmpi(lang,'n')
        arr                 = 'fooCellN';
        property            = 'excelFooterNor';
        field               = 'footerNor';
        graphSettings.(arr) = cell(graphSettings.rows,graphSettings.colWidth);
        language            = 'norwegian';
    else
        arr                 = 'fooCellE';
        property            = 'excelFooterEng';
        field               = 'footerEng';
        graphSettings.(arr) = cell(1,graphSettings.colWidth);
        language            = 'english';
    end    
    
    footer           = graphSettings.(field);
    old              = plotter.language;
    plotter.language = language;
    if ~isempty(plotter.(property))
        eFooter               = plotter.(property);
        eFooter               = nb_localVariables(graph.localVariables,eFooter);
        eFooter               = nb_localFunction(plotter,eFooter);
        footer                = [eFooter;footer];
        graphSettings.(field) = footer; 
    end
    plotter.language = old;
    
    foo = str2Excel(footer);
    if strcmpi(S.excelStyle,'fsr')  % No bold footnotes in FSR style
        foo = removeBold(foo);
        foo = removeCurlyBrackets(foo);
    end
    foo                      = removeTextBackSlashes(foo);
    graphSettings.(arr){1,1} = foo;
    
end

%==================================================================
% Look up types in cell data of nb_cs 
%==================================================================

function graphSettings = lookUpTypes(graphSettings,plotter,language)
          
    switch lower(language)

        case 'both'

            for jj = 3:size(graphSettings.cellData,1)

                typeT = nb_graph_package.findVariableName(plotter.lookUpMatrix,graphSettings.cellData{jj,1},'norsk');
                if isstruct(plotter.localVariables)
                    typeT = nb_localVariables(plotter.localVariables,typeT);
                end
                try 
                    typeT  = nb_localFunction(plotter,typeT);
                catch
                end %#ok<CTCH>
                graphSettings.cellData{jj,1} = correctType(typeT); %Robust concatenation merge when '-' is found at the end of a row.

                typeT = nb_graph_package.findVariableName(plotter.lookUpMatrix,graphSettings.cellData{jj,2},'english');
                if isstruct(plotter.localVariables)
                    typeT = nb_localVariables(plotter.localVariables,typeT);
                end
                try 
                    typeT  = nb_localFunction(graph.plotter,typeT);
                catch
                end %#ok<CTCH>
                graphSettings.cellData{jj,2} = correctType(typeT); %Robust concatenation merge when '-' is found at the end of a row.

            end

        otherwise

            for jj = 2:size(graphSettings.cellData,1)
                typeT = nb_graph_package.findVariableName(plotter.lookUpMatrix,graphSettings.cellData{jj,1},language);
                if isstruct(plotter.localVariables)
                    typeT = nb_localVariables(plotter.localVariables,typeT);
                end
                try 
                    typeT = nb_localFunction(graph.plotter,typeT);
                catch
                end %#ok<CTCH>
                graphSettings.cellData{jj,1} = correctType(typeT); %Robust concatenation merge when '-' is found at the end of a row.
            end

    end

end

%==================================================================
% Look up variables in cell data
%==================================================================

function graphSettings = lookUpVariables(graphSettings,plotter,language)
                                    
    switch lower(language)

        case 'both'

            for jj = graphSettings.start:size(graphSettings.cellData,2)

                tempVar = nb_graph_package.findVariableName(plotter.lookUpMatrix,graphSettings.cellData{1,jj},'norsk');
                if isstruct(plotter.localVariables)
                    tempVar = nb_localVariables(plotter.localVariables,tempVar);
                end
                try 
                    tempVar = nb_localFunction(plotter,tempVar);
                catch 
                end %#ok<CTCH>
                graphSettings.cellData{1,jj} = correctType(tempVar); %Robust concatenation merge when '-' is found at the end of a row.
                tempVar                      = nb_graph_package.findVariableName(plotter.lookUpMatrix,graphSettings.cellData{2,jj},'english');
                if isstruct(plotter.localVariables)
                    tempVar = nb_localVariables(plotter.localVariables,tempVar);
                end
                try 
                    tempVar = nb_localFunction(plotter,tempVar);
                catch 
                end %#ok<CTCH>
                graphSettings.cellData{2,jj} = correctType(tempVar); %Robust concatenation merge when '-' is found at the end of a row.

            end

        otherwise

            for jj = graphSettings.start:size(graphSettings.cellData,2)
                tempVar = nb_graph_package.findVariableName(plotter.lookUpMatrix,graphSettings.cellData{1,jj},language);
                if isstruct(plotter.localVariables)
                    tempVar = nb_localVariables(plotter.localVariables,tempVar);
                end
                try 
                    tempVar = nb_localFunction(plotter,tempVar);
                catch
                end %#ok<CTCH>
                graphSettings.cellData{1,jj} = correctType(tempVar); %Robust concatenation merge when '-' is found at the end of a row.
            end

    end
    
end

%==================================================================
% Look up variables in cell data
%==================================================================

function graphSettings = lookUpElements(graphSettings,plotter,language)

    for jj = 1:size(graphSettings.cellData,1)
        for cc = 1:size(graphSettings.cellData,2)
            element = nb_graph_package.findVariableName(plotter.lookUpMatrix,graphSettings.cellData{jj,cc},language);
            if isstruct(plotter.localVariables)
                element = nb_localVariables(plotter.localVariables,element);
            end
            try element = nb_localFunction(graph.plotter,element);catch; end %#ok<CTCH>
            graphSettings.cellData{jj,cc} = correctType(element); %Robust concatenation merge when '-' is found at the end of a row.
        end
    end

end

%==================================================================
% Remove variables from data of the graph
%==================================================================

function graphData = removeVars(graph,graphData)

    % Remove the variables which cannot be published
    if ~isempty(graph.remove) && ~isa(graph.plotter,'nb_table_cell')
        try
            graphData = graphData.deleteVariables(graph.remove);
        catch %#ok<CTCH>
            if strcmpi(language,'english') || strcmpi(language,'engelsk')
                figName = graph.figureNameEng;
            else
                figName = graph.figureNameNor;
            end
            error([mfilename ':: Error while removing the not published variables for the figure ' figName])
        end
    end

end

%==========================================================================
function outType = correctType(typeT)
% Concatenate multi-line chars to a string. 
%
% If a row ends with '-' it will not add white space between the
% end of line ii and the start of line ii + 1.

    if size(typeT,1) == 1 || isempty(typeT)
        outType = typeT;
        return
    end

    typeT1   = strtrim(typeT(1,:));
    indOld   = strfind(typeT1,'-');
    if isempty(indOld)
        outType = typeT1;
    else
        if indOld(end) == size(typeT1,2)
            outType = typeT1(1,1:end-1);
        else
            outType = typeT1;
        end
    end

    for gg = 2:size(typeT,1)

        typeTgg = strtrim(typeT(gg,:)); 
        indNew  = strfind(typeTgg,'-');
        if isempty(indNew)
            tempType = typeTgg;
        else
            if indNew(end) == size(typeTgg,2)
                tempType = typeTgg(1,1:end-1);
            else
                tempType = typeTgg;
            end
        end

        if isempty(indOld)
            outType = [outType,' ', tempType]; %#ok
        else
            outType = [outType, tempType]; %#ok
        end
        
        indOld = indNew;
        
    end

end

%==========================================================================
function out = str2Excel(in)
% - in  : A cellstr array
% - out : A char

    if ~isempty(in)
        f   = in{1};
        f   = strrep(f,'\it','');
        f   = strrep(f,'\rm','');
        out = f;
        for jj = 2:length(in)
            f   = in{jj};
            f   = strrep(f,'\it','');
            f   = strrep(f,'\rm','');
            out = [out char(10) f]; %#ok
        end
    else
        out = '';
    end

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
function [c,super] = getSuperIndex(c)

    [s1,s2] = size(c);
    super   = {};
    for ii = 1:s1
        for jj = 1:s2
            if ischar(c{ii,jj})
                [s,e] = regexp(c{ii,jj},'\^\{[^\^]+\}','start','end');
                if ~isempty(s)
                    % Remove the latex syntax ^{...} and adjust index
                    % accordingly
                    r1       = 0:3:3*size(s,2)-1;
                    r2       = 3:3:3*size(s,2);
                    s        = s - r1;
                    e        = e - r2;
                    c{ii,jj} = strrep(c{ii,jj},'^{','');
                    c{ii,jj} = strrep(c{ii,jj},'}','');
                    ind      = {[ii jj],s,e};
                    super    = [super, {ind}]; %#ok<AGROW>
                end
            end
        end
    end

end

%==========================================================================
function [c,bold] = getBoldIndex(c)

    [s1,s2] = size(c);
    bold    = {};
    for ii = 1:s1
        for jj = 1:s2
            if ischar(c{ii,jj})
                [s,e] = regexp(c{ii,jj},'\{\\bf[^\}]+\}','start','end');
                if ~isempty(s)
                    % Remove the latex syntax ^{...} and adjust index
                    % accordingly
                    r1       = 0:5:5*size(s,2)-1;
                    r2       = 5:5:5*size(s,2);
                    s        = s - r1;
                    e        = e - r2;
                    c{ii,jj} = strrep(c{ii,jj},'{\bf','');
                    c{ii,jj} = strrep(c{ii,jj},'}','');
                    ind      = {[ii jj],s,e};
                    bold     = [bold, {ind}]; %#ok<AGROW>
                end
            end
        end
    end

end

%==========================================================================
function interpretCharType(Activesheet,values,type)

    for ii = 1:length(values)
       
        ind = values{ii}{1};
        s   = values{ii}{2};
        e   = values{ii}{3};
        for jj = 1:size(s,2)
            xlcell     = [char(nb_xlsNum2Column(ind(2))),int2str(ind(1))];
            ExActRange = get(Activesheet,'Range',xlcell);
            for kk = s(jj):e(jj)
                ExChar = get(ExActRange,'Characters',kk,1); 
                set(ExChar.Font,type,true); 
            end
        end
        
    end

end

%==========================================================================
function fcstInd = interpretForecastDate(graphData,temp,forecastDate,localVars)

    frequency = graphData.frequency; 
    if isempty(forecastDate)

        s       = size(temp,2) - 1;
        indAll  = nan(1,s);
        fcstInd = indAll; 

    elseif length(forecastDate) == 1

        if isstruct(localVars)
            forecastDate{1} = nb_localVariables(localVars,forecastDate{1});
        end

        if isempty(forecastDate{1})
            s       = size(temp,2) - 1;
            indAll  = nan(1,s);
            fcstInd = indAll;
        else

            freq    = nb_date.getFreq(forecastDate{1});
            dateStr = nb_date.toDate(forecastDate{1},freq);
            dateStr = dateStr.toString('xls',0);
            ind     = find(strcmp(dateStr,temp(:,1)),1);
            if isempty(ind)

                % Here we get if the forecast date given is stripped from 
                % the data. We will the just iterate forward to find the
                % next valid date
                dateObj = nb_date.toDate(dateStr,frequency);
                kk      = 0;
                while isempty(ind)

                    kk      = kk + 1;
                    dateObj = dateObj + 1;
                    dateStr = dateObj.toString('xls',0);
                    ind     = find(strcmp(dateStr,temp(:,1)),1);
                    if kk > 10
                        ind = nan;
                        break;
                    end

                end

            end

            fcstInd = repmat(ind,[1,size(temp,2) - 1]);

        end

    else

        s      = size(temp,2) - 1;
        indAll = nan(1,s);
        for jj = 1:2:size(forecastDate,2)

            if isstruct(localVars)
                forecastDate{jj+1} = nb_localVariables(localVars,forecastDate{jj+1});
            end

            if isempty(forecastDate{jj + 1})
                continue
            end

            indV = strcmp(forecastDate{jj},temp(1,2:end));
            if any(indV)
                if strcmpi(forecastDate{jj + 1},'start')
                    date    = graphData.startDate;
                    varData = getVariable(graphData,forecastDate{jj});
                    ind     = find(isfinite(varData),1,'first') - 1;
                    date    = date + ind;
                    dateStr = date.toString('xls',0);
                    ind     = find(strcmp(dateStr,temp(:,1)),1);
                else
                    freq    = nb_date.getFreq(forecastDate{jj + 1});
                    dateStr = nb_date.toDate(forecastDate{jj + 1},freq);
                    dateStr = dateStr.toString('xls',0);
                    ind     = find(strcmp(dateStr,temp(:,1)),1);
                end

                if isempty(ind)

                    % Here we get if the forecast date given is stripped from 
                    % the data. We will then just iterate forward to find the 
                    % next valid date
                    dateObj = nb_date.toDate(dateStr,frequency);
                    kk      = 0;
                    while isempty(ind)

                        kk      = kk + 1;
                        dateObj = dateObj + 1;
                        dateStr = dateObj.toString('xls',0);
                        ind     = find(strcmp(dateStr,temp(:,1)),1);
                        if kk > 10
                            ind = nan;
                            break;
                        end

                    end

                end
                indAll(indV) = ind;
            end

        end
        fcstInd = indAll;

    end

end

%==========================================================================
function fcstInd = interpretForecastTypes(temp,forecastTypes)

    firstColumn = temp(:,1);
    [~,fcstInd] = ismember(forecastTypes,firstColumn);

end

%==========================================================================
function range = getRange(rangeIn,r,c,rr,cc)

    if nargin < 4
        range = nb_excelRange(rangeIn,r,c,0,0);
    else
        range = nb_excelRange(rangeIn,rr,cc,r,c);
    end

end

%==========================================================================
function numVars = checkLastColForData(numCol,cData)
    names   = {'Anslag','Projections','Anslag/Projections'};
    lastCol = cData(:,end);
    idx     = ~cellfun(@isempty,lastCol);
    if sum(idx) == 1 && ischar(lastCol{idx}) && ismember(lastCol(idx),names)
        numVars = numCol - 1;
    else
        numVars = numCol;
    end
end

%==================================================================
% Formatting Excel Sheets
%==================================================================

function formatIndexPage(S,Excel,i)

    % Get a handle to the current sheet
    current_sheet = get(S.Sheets, 'Item', (i-S.index_adjust));
    invoke(current_sheet, 'Activate');
    Activesheet = Excel.Activesheet;

    % Set the font color, size and fontweight of
    % the name of the title
    ExActRange = get(Activesheet,'Range','B2:B2');
    if strcmpi(S.excelStyle,'mpr')
        ExActRange.Font.Color =-4030384;
    else
        ExActRange.Font.Color = 4626167;
    end
    ExActRange.Font.Size  = 20;
    ExActRange.Select;
    set(Excel.Selection.Font,'Bold',1);

    % Set the font color, size and fontweight of
    % the name of the subtitle
    ExActRange = get(Activesheet,'Range','B3:B3');
    ExActRange.Font.Color = -4030384;
    ExActRange.Font.Size  = 15;
    ExActRange.Select;
    set(Excel.Selection.Font,'Bold',1);

    % Set the fontweight and number format of the
    % date
    ExActRange = get(Activesheet,'Range','B4:B4');
    ExActRange.NumberFormat = '[$-F800]dddd, mmmm dd, yyyy';
    ExActRange.Select;
    set(Excel.Selection.Font,'Bold',1);

    % Set the fontweight of the "Innhold"
    % or "Index"
    ExActRange = get(Activesheet,'Range','B6:B6');
    ExActRange.Select;
    set(Excel.Selection.Font,'Bold',1);

    % Autofit the B column
    ExActRange = get(Activesheet,'Columns','B:B');
    ExActRange.Select;
    invoke(Excel.Selection.Columns,'Autofit');

    % Make the hyperlinks
    try %#ok<TRYNC>
        nb_addHyperlink(Activesheet);
    end

    for ll = 1:S.numberOfGraphs
        range      = getRange('A6:A6',ll,1,1,1);
        ExActRange = get(Activesheet,'Range',range);
        name       = S.sheetNames{ll};
        Activesheet.HyperLinks.Add(ExActRange, '',['''' name '''!A1']);
    end

    % Remove borders
    Excel.ActiveWindow.DisplayGridlines = 0;

    % Change the font name
    ExActRange                = Activesheet.Cells;
    if strcmpi(S.excelStyle,'mpr')
        ExActRange.Font.Name      = 'Arial';
    else
        ExActRange.Font.Name      = 'Univers 45 Light';
    end
    ExActRange.Font.Size      = 10;
    ExActRange.Font.Underline = false;

    % Font size of title
    ExActRange = get(Activesheet,'Range','B2:B2');
    ExActRange.Font.Size  = 20;
    if strcmpi(S.excelStyle,'fsr')
        ExActRange.Font.Name  = 'Times New Roman';
    end

    % Font size of subtitle
    ExActRange = get(Activesheet,'Range','B3:B3');
    ExActRange.Font.Size  = 15;

    % Delete empty rows for FSR style
    % and set font
    if strcmpi(S.excelStyle,'fsr')
        ExActRange = get(Activesheet,'Rows','3:5');
        ExActRange.Delete;
    end

    % Set the selection to be A1:A1
    ExActRange = get(Activesheet,'Range','A1:A1');
    ExActRange.Select;

end

%==========================================================================
function Activesheet = formatTS(S,graphSettings,Excel,i)

    % Get a handle to the current sheet
    current_sheet = get(S.Sheets, 'Item', (i-S.index_adjust));
    invoke(current_sheet, 'Activate');
    Activesheet = Excel.Activesheet;

    % Change the font name
    ExActRange = Activesheet.Cells;
    ExActRange.Font.Name = 'Arial';
    ExActRange.Font.Size = 10;

    % Autofit the columns of each of the columns
    % with data
    range      = nb_xlsNum2Column([2,graphSettings.numberOfColumns]);
    ExActRange = get(Activesheet,'Columns',[range{1} ':' range{2}]);
    ExActRange.Select;
    invoke(Excel.Selection.Columns,'Autofit');

    % Then we make them all equal to the widest!
    % .. if we are using MPR style
    if strcmpi(S.excelStyle,'mpr')
        range  = 2:graphSettings.numberOfColumns;
        range  = nb_xlsNum2Column(range);
        widths = nan(1,graphSettings.numberOfColumns-1);
        for ii = 1:length(range)
            ExActRange = get(Activesheet,'Columns',range{ii});
            widths(ii) = ExActRange.ColumnWidth;
        end
        maxWidth = max(widths);
        for ii = 1:length(range)
            ExActRange = get(Activesheet,'Columns',range{ii});
            ExActRange.ColumnWidth = maxWidth;
        end
    end

    % Set the column width of the first column, so
    % all the dates will be shown
    ExActRange = get(Activesheet,'Columns','A:A');
    ExActRange.ColumnWidth = 10.14;

    % Correct the first figure title 
    ExActRange = get(Activesheet,'Range','A1:I1');
    ExActRange.Interior.Color = 15790320;
    ExActRange.Select;
    Excel.Selection.MergeCells = true;
    set(Excel.Selection.Font,'Bold',1);
    set(Excel.Selection,'WrapText',1);
    ExActRange = get(Activesheet,'Rows','1:1');
    if strcmpi(S.excelStyle,'mpr')
        rows                 = length(graphSettings.figureTitleNor);
        ExActRange.RowHeight = 15*rows;
    else
       ExActRange.RowHeight = 70;
       set(Excel.Selection,'VerticalAlignment',-4108);   % center align
       set(Excel.Selection,'HorizontalAlignment',-4131); % left align
   end

    % Correct the first footer
    ExActRange = get(Activesheet,'Range','A2:I2');
    ExActRange.Select;
    Excel.Selection.MergeCells = true;
    set(Excel.Selection,'WrapText',1);
    ExActRange = get(Activesheet,'Rows','2:2');
    footerN    = graphSettings.footerNor;

    if strcmpi(S.excelStyle,'mpr')
        rows                 = length(footerN);
        ExActRange.RowHeight = 15*rows;
        ExActRange.Font.Size = 8;
    else
        ExActRange.RowHeight = 70;
        set(Excel.Selection,'VerticalAlignment',-4108);   % center align
        set(Excel.Selection,'HorizontalAlignment',-4131); % left align
    end

    if strcmpi(S.language,'both')

        % Correct the second figure title (english)
        ExActRange = get(Activesheet,'Range','A4:I4');
        ExActRange.Interior.Color = 15790320;
        ExActRange.Select;
        Excel.Selection.MergeCells = true;
        set(Excel.Selection.Font,'Bold',1);
        set(Excel.Selection,'WrapText',1);
        ExActRange = get(Activesheet,'Rows','4:4');
        if strcmpi(S.excelStyle,'mpr')
            rows = length(graphSettings.figureTitleEng);
            ExActRange.RowHeight = 15*rows;
        else
            ExActRange.RowHeight = 70;
            set(Excel.Selection,'VerticalAlignment',-4108);   % center align
            set(Excel.Selection,'HorizontalAlignment',-4131); % left align
        end

        % Correct the second footer (english)
        ExActRange = get(Activesheet,'Range','A5:I5');
        ExActRange.Select;
        Excel.Selection.MergeCells = true;
        set(Excel.Selection,'WrapText',1);
        ExActRange = get(Activesheet,'Rows','5:5');
        footerE    = graphSettings.footerEng;
        if strcmpi(S.excelStyle,'mpr')
            rows = length(footerE);
            ExActRange.RowHeight = 15*rows;
            ExActRange.Font.Size = 8;
        else
            ExActRange.RowHeight = 70;
            set(Excel.Selection,'VerticalAlignment',-4108);   % center align
            set(Excel.Selection,'HorizontalAlignment',-4131); % left align
        end

        cellNumber  = 6;
        startNumber = 9;

    else
        cellNumber  = 3;
        startNumber = 5;
    end

    if strcmpi(S.language,'english') || strcmpi(S.language,'engelsk')
        string = '''Index''!A1';
    else
        string = '''Innhold''!A1';
    end

    % Add hyperlink to the Innhold/Index page
    range      = getRange('A1:A1',cellNumber - 1,0,1,1);
    ExActRange = get(Activesheet,'Range',range);
    Activesheet.HyperLinks.Add(ExActRange, '',string);
    if strcmpi(S.excelStyle,'mpr')
        ExActRange.Font.Size = 9;
    else
        ExActRange.Font.Size = 11;
    end

    % Add hyperlink to the Index page
    if strcmpi(S.language,'both')

        range      = getRange('B1:B1',cellNumber - 1,0,1,1);
        ExActRange = get(Activesheet,'Range',range);
        Activesheet.HyperLinks.Add(ExActRange, '','''Index''!A1');
        if strcmpi(S.excelStyle,'mpr')
            ExActRange.Font.Size = 9;
        else
            ExActRange.Font.Size = 11;
        end
    end

    % Set the color of the Anslag/Forecast
    % text if we are using MPR style
    if strcmpi(S.excelStyle,'mpr')
        range      = getRange('C1:C1',cellNumber - 1,0,1,1);
        ExActRange = get(Activesheet,'Range',range);
        ExActRange.Font.Color = -4030384;
        ExActRange.Font.Size = 9;
    end

    if graphSettings.notPublished

        range = getRange('A1:A1',cellNumber + 1,1,7,4);

        % Merge the cells of the text
        % saying that the data are not
        % published
        ExActRange = get(Activesheet,'Range',range);
        ExActRange.Select;
        Excel.Selection.MergeCells = true;
        set(Excel.Selection,'HorizontalAlignment',-4108); % Centered horizontally
        set(Excel.Selection,'VerticalAlignment',-4108); % Centered vertically
        set(Excel.Selection,'WrapText',1);
        set(Excel.Selection.Font,'Bold',1);

        % Setting the color of the 
        % cells
        ExActRange = get(Activesheet,'Range',range);
        ExActRange.Interior.Color = 15790320;

    else

        if strcmpi(S.language,'both')
            start   = 'A10:A10';
            varRows = 2;
        else
            start   = 'A6:A6';
            varRows = 1;
        end

        % Set the background color of the variables
        startBC    = getRange('A1:A1',cellNumber + 1,0,1,1);
        range      = getRange(startBC,varRows,graphSettings.numberOfVars);
        ExActRange = get(Activesheet,'Range',range);
        ExActRange.Interior.Color = 15790320;
        ExActRange.Font.Size = 9;
        if strcmpi(S.excelStyle,'mpr')
            ExActRange.HorizontalAlignment = 3; % Centered
        else
            ExActRange.Select;
            set(Excel.Selection,'HorizontalAlignment',-4152);
        end

        % Add border below variables if we are
        % using the MPR style
        if strcmpi(S.excelStyle,'mpr')
            startBC    = getRange('A1:A1',cellNumber + varRows,0,1,1);
            range      = getRange(startBC,1,graphSettings.numberOfVars);
            ExActRange = get(Activesheet,'Range',range);
            my_border  = get(ExActRange.Borders, 'Item', 9);
            my_border.LineStyle = 1;
        end

        % Set the background color of the
        % dates
        range      = getRange(start,graphSettings.numberOfRows - startNumber,1);
        ExActRange = get(Activesheet,'Range',range);
        ExActRange.Interior.Color = 15790320;
        if strcmpi(S.excelStyle,'mpr')
            ExActRange.Font.Size = 9;
        else
            ExActRange.Font.Size = 10;
        end

        % Set the number format to only two decimals
        % and for FSR style set borders
        startNum   = getRange(start,0,1,1,1);
        range      = getRange(startNum,graphSettings.numberOfRows - startNumber,...
                              graphSettings.numberOfColumns-1);
        ExActRange = get(Activesheet,'Range',range);
        if strcmpi(S.excelStyle,'fsr')
            for ii = 7:12
                my_border  = get(ExActRange.Borders, 'Item', ii);
                my_border.LineStyle = 1;
                my_border.Color     = 14277081;
            end
        end
        try
            ExActRange.NumberFormat = '0.00';
        catch  %#ok<CTCH>
            ExActRange.NumberFormat = '0,00';
        end

        % Set the color of the forecast data
        start  = getRange('B1:B1',cellNumber + 1,0,1,1);
        ind    = graphSettings.fcstInd;
        endInd = graphSettings.dataEnd;
        for ss = 1:size(ind,2)

            if ~isnan(ind(ss))
                num                   = endInd - ind(ss) + 1;
                range                 = getRange(start,ind(ss)-1,ss - 1,num,1);
                ExActRange            = get(Activesheet,'Range',range);
                ExActRange.Font.Color = -4030384;
            end

        end

    end

    % Set the selection to be A1:A1
    ExActRange = get(Activesheet,'Range','A1:A1');
    ExActRange.Select;
                            
end

%==========================================================================
function Activesheet = formatCell(S,graphSettings,Excel,i)

    % Get a handle to the current sheet
    current_sheet = get(S.Sheets, 'Item', (i-S.index_adjust));
    invoke(current_sheet, 'Activate');
    Activesheet = Excel.Activesheet;

    % Change the font name
    ExActRange           = Activesheet.Cells;
    ExActRange.Font.Name = 'Arial';
    ExActRange.Font.Size = 10;

    if strcmpi(S.language,'both')
        cellNumber  = 6;
        startAuto   = 'A8:A8';
        startNumber = 7;
        varRows     = 1;
        typeCols    = 1;
    else
        cellNumber  = 3;
        startAuto   = 'A5:A5';
        startNumber = 4;
        varRows     = 1;
        typeCols    = 1;
    end

    % Autofit the columns of the data
    range      = nb_xlsNum2Column([typeCols+1,graphSettings.numberOfColumns]);
    ExActRange = get(Activesheet,'Columns',[range{1} ':' range{2}]);
    ExActRange.Select;
    invoke(Excel.Selection.Columns,'Autofit');

    % Then we make them all equal to the widest!
    % .. if we are using MPR style
    if strcmpi(S.excelStyle,'mpr')
        range  = 2:2+graphSettings.numberOfColumns-typeCols-1;
        range  = nb_xlsNum2Column(range);
        widths = nan(1,graphSettings.numberOfColumns-1);
        for ii = 1:length(range)
            ExActRange = get(Activesheet,'Columns',range{ii});
            widths(ii) = ExActRange.ColumnWidth;
        end
        maxWidth = max(widths);
        for ii = 1:length(range)
            ExActRange = get(Activesheet,'Columns',range{ii});
            ExActRange.ColumnWidth = maxWidth;
        end
    end

    % Autofit the first column based on the
    % width of the type names only
    range      = getRange(startAuto,graphSettings.numberOfRows - startNumber,1);
    ExActRange = get(Activesheet,'Range',range);
    ExActRange.Select;
    invoke(Excel.Selection.Columns,'Autofit');

    % Autofit the second column based on the
    % width of the type names only
    if strcmpi(S.language,'both')
        startAuto2 = getRange(startAuto,0,1,1,1);
        range      = getRange(startAuto2,graphSettings.numberOfRows - startNumber,1);
        ExActRange = get(Activesheet,'Range',range);
        ExActRange.Select;
        invoke(Excel.Selection.Columns,'Autofit');
    end

    % Correct the first figure title 
    ExActRange = get(Activesheet,'Range','A1:I1');
    ExActRange.Interior.Color = 15790320;
    ExActRange.Select;
    Excel.Selection.MergeCells = true;
    set(Excel.Selection.Font,'Bold',1);
    set(Excel.Selection,'WrapText',1);
    ExActRange = get(Activesheet,'Rows','1:1');
    rows = length(graphSettings.figureTitleNor);
    ExActRange.RowHeight = 15*rows;

    % Correct the first footer
    ExActRange = get(Activesheet,'Range','A2:I2');
    ExActRange.Select;
    Excel.Selection.MergeCells = true;
    set(Excel.Selection,'WrapText',1);
    ExActRange           = get(Activesheet,'Rows','2:2');
    footerN              = graphSettings.footerNor;
    rows                 = length(footerN);
    ExActRange.RowHeight = 15*rows;
    ExActRange.Font.Size = 8;

    if strcmpi(S.language,'both')

        % Correct the second figure title (english)
        ExActRange = get(Activesheet,'Range','A4:I4');
        ExActRange.Interior.Color = 15790320;
        ExActRange.Select;
        Excel.Selection.MergeCells = true;
        set(Excel.Selection.Font,'Bold',1);
        set(Excel.Selection,'WrapText',1);
        ExActRange = get(Activesheet,'Rows','4:4');
        rows = length(graphSettings.figureTitleEng);
        ExActRange.RowHeight = 15*rows;

        % Correct the second footer (english)
        ExActRange = get(Activesheet,'Range','A5:I5');
        ExActRange.Select;
        Excel.Selection.MergeCells = true;
        set(Excel.Selection,'WrapText',1);
        ExActRange           = get(Activesheet,'Rows','5:5');
        footerE              = graphSettings.footerEng;
        rows                 = length(footerE);
        ExActRange.RowHeight = 15*rows;
        ExActRange.Font.Size = 8;

    end

    % Add hyperlink to the Innhold page
    range      = getRange('A1:A1',cellNumber - 1,0,1,1);
    ExActRange = get(Activesheet,'Range',range);
    Activesheet.HyperLinks.Add(ExActRange, '','''Innhold''!A1');
    if strcmpi(excelStyle,'mpr')
        ExActRange.Font.Size = 9;
    else
        ExActRange.Font.Size = 11;
    end

    % Add hyperlink to the Index page
    range      = getRange('B1:B1',cellNumber - 1,0,1,1);
    ExActRange = get(Activesheet,'Range',range);
    Activesheet.HyperLinks.Add(ExActRange, '','''Index''!A1');
    if strcmpi(excelStyle,'mpr')
        ExActRange.Font.Size = 9;
    else
        ExActRange.Font.Size = 11;
    end


    % Set the color of the Anslag/Projections
    % text if we are using MPR style

    if strcmpi(S.excelStyle,'mpr')
        range      = getRange('C1:C1',cellNumber - 1,0,1,1);
        ExActRange = get(Activesheet,'Range',range);
        ExActRange.Font.Color = -4030384;
        ExActRange.Font.Size = 9;
    end

    if graphSettings.notPublished

        range = getRange('A1:A1',cellNumber + 1,1,7,4);

        % Merge the cells of the text
        % saying that the data are not
        % published
        ExActRange = get(Activesheet,'Range',range);
        ExActRange.Select;
        Excel.Selection.MergeCells = true;
        set(Excel.Selection,'HorizontalAlignment',-4108);
        set(Excel.Selection,'VerticalAlignment',-4108);
        set(Excel.Selection,'WrapText',1);
        set(Excel.Selection.Font,'Bold',1);

        % Setting the color of the 
        % cells
        ExActRange = get(Activesheet,'Range',range);
        ExActRange.Interior.Color = 15790320;

    else

        if strcmpi(S.language,'both')
            start = 'A8:A8';
        else
            start = 'A5:A5';
        end

        % Set the background color of the variables
        startBC    = getRange('A1:A1',cellNumber + 1,0,1,1);
        range      = getRange(startBC,varRows,graphSettings.numberOfColumns);
        ExActRange = get(Activesheet,'Range',range);
        ExActRange.Interior.Color = 15790320;
        ExActRange.Font.Size = 9;
        if strcmpi(S.excelStyle,'mpr')
            ExActRange.HorizontalAlignment = 3; % Centered
        else
            ExActRange.Select;
            set(Excel.Selection,'HorizontalAlignment',-4152);
        end

        % Add border below variables if we are
        % using the MPR style
        if strcmpi(S.excelStyle,'mpr')
            startBC    = getRange('A1:A1',cellNumber + varRows,0,1,1);
            range      = getRange(startBC,1,graphSettings.numberOfColumns);
            ExActRange = get(Activesheet,'Range',range);
            my_border  = get(ExActRange.Borders, 'Item', 9);
            my_border.LineStyle = 1;
        end

        % Set the background color of the
        % types
        range      = getRange(start,graphSettings.numberOfRows-startNumber,typeCols);
        ExActRange = get(Activesheet,'Range',range);
        ExActRange.Interior.Color = 15790320;
        if strcmpi(S.excelStyle,'mpr') 
            ExActRange.Font.Size = 9;
        else
            ExActRange.Font.Size = 10;
        end

        % Set the number format to only two decimals
        % and for FSR style set borders
        startNum   = getRange(start,0,typeCols,1,1);
        range      = getRange(startNum,graphSettings.numberOfRows - startNumber,...
                              graphSettings.numberOfColumns - typeCols);
        ExActRange = get(Activesheet,'Range',range);
        if strcmpi(S.excelStyle,'fsr')
            for ii = 7:12
                my_border           = get(ExActRange.Borders, 'Item', ii);
                my_border.LineStyle = 1;
                my_border.Color     = 14277081;
            end
        end
        try
            ExActRange.NumberFormat = '0.00';
        catch  %#ok<CTCH>
            ExActRange.NumberFormat = '0,00';
        end

    end

    % Change the font name
    % .. if we are using MPR style
    if strcmpi(S.excelStyle,'mpr')
        ExActRange = Activesheet.Cells;
        ExActRange.Font.Name = 'Univers 45 Light';
    end

    % Set the selection to be A1:A1
    ExActRange = get(Activesheet,'Range','A1:A1');
    ExActRange.Select;
                            
end

%==========================================================================

function Activesheet = formatDefault(S,graphSettings,Excel,i)

    % Get a handle to the current sheet
    current_sheet = get(S.Sheets, 'Item', (i-S.index_adjust));
    invoke(current_sheet, 'Activate');
    Activesheet = Excel.Activesheet;

    % Change the font name
    ExActRange = Activesheet.Cells;
    ExActRange.Font.Name = 'Arial';
    ExActRange.Font.Size = 10;

    if strcmpi(S.language,'both')
        cellNumber  = 6;
        startAuto   = 'A10:A10';
        startNumber = 9;
        varRows     = 2;
        typeCols    = 2;
    else
        cellNumber  = 3;
        startAuto   = 'A6:A6';
        startNumber = 5;
        varRows     = 1;
        typeCols    = 1;
    end

    % Autofit the columns of the data
    range      = nb_xlsNum2Column([typeCols+1,graphSettings.numberOfColumns]);
    ExActRange = get(Activesheet,'Columns',[range{1} ':' range{2}]);
    ExActRange.Select;
    invoke(Excel.Selection.Columns,'Autofit');

    % Then we make them all equal to the widest!
    % .. if we are using MPR style
    if strcmpi(S.excelStyle,'mpr')
        range  = 2:2+graphSettings.numberOfColumns - typeCols - 1;
        range  = nb_xlsNum2Column(range);
        widths = nan(1,graphSettings.numberOfColumns - 1);
        for ii = 1:length(range)
            ExActRange = get(Activesheet,'Columns',range{ii});
            widths(ii) = ExActRange.ColumnWidth;
        end
        maxWidth = max(widths);
        for ii = 1:length(range)
            ExActRange = get(Activesheet,'Columns',range{ii});
            ExActRange.ColumnWidth = maxWidth;
        end
    end

    % Autofit the first column based on the
    % width of the type names only
    range      = getRange(startAuto,graphSettings.numberOfRows-startNumber,1);
    ExActRange = get(Activesheet,'Range',range);
    ExActRange.Select;
    invoke(Excel.Selection.Columns,'Autofit');

    % Autofit the second column based on the
    % width of the type names only
    if strcmpi(S.language,'both')
        startAuto2 = getRange(startAuto,0,1,1,1);
        range      = getRange(startAuto2,graphSettings.numberOfRows - startNumber,1);
        ExActRange = get(Activesheet,'Range',range);
        ExActRange.Select;
        invoke(Excel.Selection.Columns,'Autofit');
    end

    % Correct the first figure title 
    ExActRange = get(Activesheet,'Range','A1:I1');
    ExActRange.Interior.Color = 15790320;
    ExActRange.Select;
    Excel.Selection.MergeCells = true;
    set(Excel.Selection.Font,'Bold',1);
    set(Excel.Selection,'WrapText',1);
    ExActRange = get(Activesheet,'Rows','1:1');

    if strcmpi(S.excelStyle,'mpr')
        rows = length(graphSettings.figureTitleNor);
        ExActRange.RowHeight = 15*rows;
    else
        ExActRange.RowHeight = 70;
        set(Excel.Selection,'VerticalAlignment',-4108);   % center align
        set(Excel.Selection,'HorizontalAlignment',-4131); % left align
    end

    % Correct the first footer
    ExActRange = get(Activesheet,'Range','A2:I2');
    ExActRange.Select;
    Excel.Selection.MergeCells = true;
    set(Excel.Selection,'WrapText',1);
    ExActRange = get(Activesheet,'Rows','2:2');
    footerN    = graphSettings.footerNor;
    if strcmpi(S.excelStyle,'mpr')
        rows                 = length(footerN);
        ExActRange.RowHeight = 15*rows;
        ExActRange.Font.Size = 8;
    else
        ExActRange.RowHeight = 70;
        set(Excel.Selection,'VerticalAlignment',-4108);   % center align
        set(Excel.Selection,'HorizontalAlignment',-4131); % left align
    end

    if strcmpi(S.language,'both')

        % Correct the second figure title (english)
        ExActRange = get(Activesheet,'Range','A4:I4');
        ExActRange.Interior.Color = 15790320;
        ExActRange.Select;
        Excel.Selection.MergeCells = true;
        set(Excel.Selection.Font,'Bold',1);
        set(Excel.Selection,'WrapText',1);
        ExActRange = get(Activesheet,'Rows','4:4');

        if strcmpi(S.excelStyle,'mpr')
            rows = length(graphSettings.figureTitleEng);
            ExActRange.RowHeight = 15*rows;
        else
            ExActRange.RowHeight = 70;
            set(Excel.Selection,'VerticalAlignment',-4108);   % center align
            set(Excel.Selection,'HorizontalAlignment',-4131); % left align
        end

        % Correct the second footer (english)
        ExActRange = get(Activesheet,'Range','A5:I5');
        ExActRange.Select;
        Excel.Selection.MergeCells = true;
        set(Excel.Selection,'WrapText',1);
        ExActRange = get(Activesheet,'Rows','5:5');
        footerE    = graphSettings.footerEng;
        if strcmpi(S.excelStyle,'mpr')
            rows                 = length(footerE);
            ExActRange.RowHeight = 15*rows;
            ExActRange.Font.Size = 8;
        else
            ExActRange.RowHeight = 70;
            set(Excel.Selection,'VerticalAlignment',-4108);   % center align
            set(Excel.Selection,'HorizontalAlignment',-4131); % left align
        end


    end

    % Add hyperlink to the Innhold page
    range      = getRange('A1:A1',cellNumber - 1,0,1,1);
    ExActRange = get(Activesheet,'Range',range);
    Activesheet.HyperLinks.Add(ExActRange, '','''Innhold''!A1');
    if strcmpi(S.excelStyle,'mpr')
        ExActRange.Font.Size = 9;
    else
        ExActRange.Font.Size = 11;
    end

    % Add hyperlink to the Index page
    range      = getRange('B1:B1',cellNumber - 1,0,1,1);
    ExActRange = get(Activesheet,'Range',range);
    Activesheet.HyperLinks.Add(ExActRange, '','''Index''!A1');
    if strcmpi(S.excelStyle,'mpr')
        ExActRange.Font.Size = 9;
    else
        ExActRange.Font.Size = 11;
    end

    % Set the color of the Anslag/Projections
    % text if we are using the MPR style
    if strcmpi(S.excelStyle,'mpr')
        range      = getRange('C1:C1',cellNumber - 1,0,1,1);
        ExActRange = get(Activesheet,'Range',range);
        ExActRange.Font.Color = -4030384;
        ExActRange.Font.Size = 9;
    end

    if graphSettings.notPublished

        range = getRange('A1:A1',cellNumber + 1,1,7,4);

        % Merge the cells of the text
        % saying that the data are not
        % published
        ExActRange = get(Activesheet,'Range',range);
        ExActRange.Select;
        Excel.Selection.MergeCells = true;
        set(Excel.Selection,'HorizontalAlignment',-4108); % Centered horizontally
        set(Excel.Selection,'VerticalAlignment',-4108); % Centered vertically
        set(Excel.Selection,'WrapText',1);
        set(Excel.Selection.Font,'Bold',1);

        % Setting the color of the 
        % cells
        ExActRange = get(Activesheet,'Range',range);
        ExActRange.Interior.Color = 15790320;

    else

        if strcmpi(S.language,'both')
            start    = 'A10:A10';
        else
            start    = 'A6:A6';
        end

        % Set the background color of the variables
        startBC    = getRange('A1:A1',cellNumber + 1,0,1,1);
        range      = getRange(startBC,varRows,graphSettings.numberOfColumns);
        ExActRange = get(Activesheet,'Range',range);
        ExActRange.Interior.Color = 15790320;
        ExActRange.Font.Size = 9;
        if strcmpi(S.excelStyle,'mpr')
            ExActRange.HorizontalAlignment = 3; % Centered
        else
            ExActRange.Select;
            set(Excel.Selection,'HorizontalAlignment',-4152);
        end

        % Add border below variables if we are
        % using the MPR style
        if strcmpi(S.excelStyle,'mpr')
            startBC    = getRange('A1:A1',cellNumber + varRows,0,1,1);
            range      = getRange(startBC,1,graphSettings.numberOfColumns);
            ExActRange = get(Activesheet,'Range',range);
            my_border  = get(ExActRange.Borders, 'Item', 9);
            my_border.LineStyle = 1;
        end

        % Set the background color of the
        % types
        range      = getRange(start,graphSettings.numberOfRows - startNumber,typeCols);
        ExActRange = get(Activesheet,'Range',range);
        ExActRange.Interior.Color = 15790320;
        if strcmpi(S.excelStyle,'mpr')
            ExActRange.Font.Size = 9;
        else
            ExActRange.Font.Size = 10;
        end

        % Set the number format to only two decimals
        % and for FSR style set borders
        startNum   = getRange(start,0,typeCols,1,1);
        range      = getRange(startNum,graphSettings.numberOfRows - startNumber,...
                              graphSettings.numberOfColumns - typeCols);
        ExActRange = get(Activesheet,'Range',range);
        if strcmpi(S.excelStyle,'fsr')
            for ii = 7:12
                my_border           = get(ExActRange.Borders, 'Item', ii);
                my_border.LineStyle = 1;
                my_border.Color     = 14277081;
            end
        end
        try
            ExActRange.NumberFormat = '0.00';
        catch  %#ok<CTCH>
            ExActRange.NumberFormat = '0,00';
        end

        % Set the color of the forecasted types
        start  = getRange('B1:B1',cellNumber + 1,0,1,1);
        ind    = graphSettings.fcstInd;
        endInd = graphSettings.dataEnd;
        for ss = 1:length(ind)

            if ~isnan(ind(ss))
                range                 = getRange(start,ind(ss)-1,typeCols-1,1,endInd-2);
                ExActRange            = get(Activesheet,'Range',range);
                ExActRange.Font.Color = -4030384;
            end

        end

    end

    % Change the font name
    % .. if we are using MPR style
    if strcmpi(S.excelStyle,'mpr')
        ExActRange = Activesheet.Cells;
        ExActRange.Font.Name = 'Univers 45 Light';
    end
    % Set the selection to be A1:A1
    ExActRange = get(Activesheet,'Range','A1:A1');
    ExActRange.Select;
                            
end




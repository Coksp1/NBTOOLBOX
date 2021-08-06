function writeSeparate(obj,folder,language,format,index,gui,template,includeFigureNumber,crop,skipConfirmation)
% Syntax:
% 
% writeSeparate(obj,folder,language,format,index,gui,template,...
% includeFigureNumber,crop)
% 
% Description:
% 
% Save the graph package to files. Each graph will be save with the name of
% the assign identifier. See the nb_graph_package.add for more on the 
% identifiers.
% 
% Input:
% 
% - obj      : An object of class nb_graph_package
% 
% - folder   : The folder to save the graphs to.
% 
% - language : The language as a string, 'english' or 
%              {'norsk'}. Will also be appended the save names.
%     
% - format   : The file format to save the graph to. See the nb_saveas
%              function for the supported formats. Default is 'pdf'.
% 
% - index    : Either a 1 x numGraphs logical or empty. Set the matching 
%              element of a graph to false to skip printing the specific
%              graph. Default is empty, i.e. to print all graphs of the 
%              package.
%
% - gui      : true or false
%
% - template : The template of the graphs to use. Default is 'current'.
%
% - includeFigureNumber : Include figure number in file names. Default
%                         is false.
%
% - crop     : true or false. Default is true. 
%
% - skipConfirmation : Skip the confirmation window and go straight to
%                      writing or not. Default is false.
%
% Examples:
%
% obj.writeSeparate('test', 'english', 'pdf');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 10
        skipConfirmation = false;
        if nargin < 9
            crop = true;
            if nargin < 8
                includeFigureNumber = false;
                if nargin < 7
                    template = 'current';
                    if nargin < 6
                        gui = 0;
                        if nargin < 5
                            index = [];
                            if nargin < 4
                                format = 'pdf';
                                if nargin<3
                                    language = '';
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    set(0,'DefaultFigureWindowStyle','normal');
    
    if skipConfirmation
       if isempty(folder)
           error([mfilename ':: The input <folder> cannot be empty if you want to skip the confirmation window.'])
       end
       yes([],[],obj,folder,language,format,index,template,gui,includeFigureNumber,crop);
       
    else
        if ~isempty(folder)
            if exist(folder,'dir')
                nb_confirmWindow(['Are you sure you want to save the ' upper(format) 's to ',...
                    'the folder ' folder],@no,@(h,e)yes(h,e,obj,folder,language,format,index,template,gui,includeFigureNumber,crop));
            else
                succ = mkdir(folder);
                if ~succ
                    nb_errorWindow(['Could not make the folder ' folder '.']) 
                else
                    yes([],[],obj,folder,language,format,index,template,gui,includeFigureNumber,crop);
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

function yes(h,~,obj,folder,language,format,index,template,gui,includeFigureNumber,crop)

    try

        if not(strcmp(folder(end),'\'))
            folder = [folder,'\'];
        end

        % Delete confirmation window
        delete(get(h,'parent'));

        % Write a copy of each graph object
        numOfGraphs   = size(obj.graphs,2);
        graphsToPrint = cell(1,numOfGraphs);
        for ii = 1:numOfGraphs
            graphsToPrint{ii} = copy(obj.graphs{ii});
        end
        if isempty(index)
            index = true(1,size(graphsToPrint,2));
        else
            if ~islogical(index)
                error([mfilename ':: The index input must be logical.'])
            end
            if size(index,2) ~= size(graphsToPrint,2)
                error([mfilename ':: The index input must be logical with size 1x' int2str(numOfGraphs) '.'])
            end
        end

        % Apply template
        %-------------------------------------------------------------
        if ~(strcmpi(template,'current') || isempty(template))
            for ii = 1:numOfGraphs
                applyTemplate(graphsToPrint{ii},template);
            end
            aRatio = getTemplateProperty(graphsToPrint{1}.plotter(1),template,'plotAspectRatio');
            pos    = getTemplateProperty(graphsToPrint{1}.plotter(1),template,'figurePosition');
        else
            aRatio = '[4,3]';
            if obj.advanced
                pos = [40,15,220,50];
            else
                pos = [40,15,186.4,43];
            end
        end

        f = nb_graphPanel(aRatio,...
             'advanced',       obj.advanced,...
             'visible',        'on',...
             'units',          'characters',...
             'position',       pos,...
             'Color',          [1 1 1],...
             'name',           'Package',...
             'numberTitle',    'off',...
             'dockControls',   'off',...
             'menuBar',        'None',...
             'toolBar',        'None',...
             'tag',            'main');
        main = f.figureHandle;                 
        movegui(main,'center');      

        % Create the menu to select the graphs
        graphMenu  = uimenu(main,'label','Graph','enable','off');
            graphs = uimenu(graphMenu,'Label','Graphs');
            if strcmpi(language,'english')
                for ii = 1:numOfGraphs-1
                    uimenu(graphs,'Label',graphsToPrint{ii}.figureNameEng,'Callback',{@nb_graph_package.changeGraphEng,graphsToPrint{ii},f,gui},'interruptible','off');
                end   
                uimenu(graphs,'Label',graphsToPrint{end}.figureNameEng,'checked','on','Callback',{@nb_graph_package.changeGraphEng,graphsToPrint{end},f,gui},'interruptible','off');
            else
                language = 'norwegian';
                for ii = 1:numOfGraphs-1
                    uimenu(graphs,'Label',graphsToPrint{ii}.figureNameNor,'Callback',{@nb_graph_package.changeGraphNor,graphsToPrint{ii},f,gui},'interruptible','off');
                end   
                uimenu(graphs,'Label',graphsToPrint{end}.figureNameNor,'checked','on','Callback',{@nb_graph_package.changeGraphNor,graphsToPrint{end},f,gui},'interruptible','off');
            end

        % Add next prev buttons
        uimenu(graphMenu,...
            'separator',    'on',...
            'label',        'Previous',...
            'callback',     {@nb_graph_package.previousGraphCallback,language,graphsToPrint,graphs,f,gui},...
            'accelerator',  'Q',...
            'interruptible','off');
        uimenu(graphMenu,...
            'label',        'Next',...
            'callback',     {@nb_graph_package.nextGraphCallback,language,graphsToPrint,graphs,f,gui},...
            'accelerator',  'A',...
            'interruptible','off');      

        % Graph the figures and save them to PDF
        inputs = {};
        if ~obj.flip
            inputs = [inputs,'-noflip'];
        end
        if obj.a4Portrait
            inputs = [inputs,'-a4Portrait'];
        end
        if ~crop
            inputs = [inputs,'-nocrop'];
        end

        number = nb_numbering(obj.start - 1,obj.chapter,language,obj.bigLetter);
        if strcmpi(language,'english')
            figTitleProperty   = 'figureTitleEng';
            graphMethod        = @graphEng;
            figureNameProperty = 'figureNameEng';
        else
            figTitleProperty   = 'figureTitleNor';
            graphMethod        = @graphNor;
            figureNameProperty = 'figureNameNor';
        end
        
    catch Err
        nb_errorWindow(['Could not write ' upper(format) 's.'], Err) 
        return
    end
    
    rethrowOnly = false;
    try

        counter   = 1;
        numbering = cell(1,size(graphsToPrint,2));
        for ii = 1:size(graphsToPrint,2)

            graphObj = graphsToPrint{ii}; 
            if isa(graphObj,'nb_graph_adv')

                % Add the figure number to the figure title
                % (temporary)
                if graphObj.plotter(1).addAdvanced
                    [numStr,counter] = nb_getFigureNumbering(graphObj,number,counter);
                    figureTitle      = graphObj.(figTitleProperty);
                    if isempty(figureTitle)
                        figureTitle{1} = numStr;
                    else
                        figureTitle{1} = [numStr ' ' figureTitle{1}];
                    end
                    numbering{ii} = numStr;
                    set(graphObj,figTitleProperty,figureTitle);
                else
                    [numStr,counter] = nb_getFigureNumbering(graphObj,number,counter);
                    numbering{ii}    = numStr;
                end

            else

                for gg = 1:length(graphObj.graphObjects)

                    plotter = graphObj.graphObjects{gg};
                    if isa(plotter,'nb_graph_adv')

                        [numStr,counter] = nb_getFigureNumbering(plotter,number,counter);
                        figureTitle      = plotter.(figTitleProperty);
                        if isempty(figureTitle)
                            figureTitle{1} = numStr;
                        else
                            figureTitle{1} = [numStr ' ' figureTitle{1}];
                        end
                        set(plotter,figTitleProperty,figureTitle);

                    else
                        number.plus(1); 
                        numStr  = char(number);
                        counter = 1;

                        title = plotter.title;
                        if isempty(title)
                            title = numStr;
                        else
                            if ischar(title)
                                title = char([numStr ' ' title(1,:)],title(2:end,:));
                            else % is a cell
                                title{1} = [numStr ' ' title{1}];
                            end
                        end
                        plotter.title = title;
                    end

                    if gg == 1
                        % For panels we only use the numbering of the first
                        % graph only
                        numbering{ii} = numStr;
                    end

                end

            end

            % Replace . and whitespace with underscore 
            numbering = regexprep(numbering,'[\s\.]','_');

            % Graph the figure
            if index(ii)
                graphObj.saveName = '';
                if isa(graphObj,'nb_graph_adv')
                    for gg = 1:size(graphObj.plotter,2)
                        graphObj.plotter(gg).printing2PDF = true;
                    end
                else
                    graphObj.printing2PDF = true;
                end
                try
                    graphMethod(graphObj,f,gui);
                catch Err
                    rethrowOnly = true;
                    nb_error(['Error while plotting the graph ' numStr '; ' graphObj.(figureNameProperty)],Err);
                end
                drawnow();
                if includeFigureNumber
                    saveName = [folder, numbering{ii} '_' obj.identifiers{ii} '_' language];
                else
                    saveName = [folder, obj.identifiers{ii} '_' language];
                end
                nb_saveas(gcf,saveName,format,inputs{:});
            end

        end

        % Enable graph menu
        %--------------------------------------------------------------
        set(graphMenu,'enable','on')
        
    catch Err
        if rethrowOnly
            rethrow(Err);
        else
            nb_errorWindow(['Could not write ' upper(format) 's. Most likely due to a file that is tried to be written to is open.'], Err);
        end
    end

end

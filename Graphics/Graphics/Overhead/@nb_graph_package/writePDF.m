function writePDF(obj,saveName,language,gui,template)
% Syntax:
% 
% writePDF(obj,saveName,language,gui,template)
% 
% Description:
% 
% Save the graph package to a pdf file
% 
% Input:
% 
% - obj           : An object of class nb_graph_package
% 
% - saveName      : The name of the pdf file as a string. If empty no file
%                   is made.
% 
% - language      : The language as a string, 'english' or 
%                   {'norsk'}
%     
% - gui           : true or false
%
% - template      : A one line char with the applied template. Default is
%                   'current', i.e. do specific template.
%
% Examples:
%
% obj.writePDF('test', 'english');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        template = 'current';
        if nargin<4
            gui = 0;
            if nargin<3
                language = '';
            end
        end
    end

    set(0,'DefaultFigureWindowStyle','normal');

    if ~isempty(saveName)
        if exist([saveName '.pdf'],'file') == 2
            dos(['del ' saveName '.pdf']);
        end
    end
    
    if isempty(saveName)
        displayValue = true; 
    else
        displayValue = false;
    end
    
    % Write a copy of each graph object
    %--------------------------------------------------------------
    numOfGraphs   = size(obj.graphs,2);
    graphsToPrint = cell(1,numOfGraphs);
    for ii = 1:numOfGraphs
        graphsToPrint{ii} = copy(obj.graphs{ii});
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
    
    % Create the figure to plot on
    %--------------------------------------------------------------
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
    % If there is only one graph in the package, we don't need the menu.
    % E.g. previewing a single graph.
    %--------------------------------------------------------------
    if numOfGraphs > 1
        graphMenu = uimenu(main,'label','Graph','enable','off');
        graphs = uimenu(graphMenu,'Label','Graphs');

        if strcmpi(language,'english')

            for ii = 1:numOfGraphs-1
                uimenu(graphs,'Label',graphsToPrint{ii}.figureNameEng,'Callback',{@nb_graph_package.changeGraphEng,graphsToPrint{ii},f,gui},'interruptible','off');
            end   
            uimenu(graphs,'Label',graphsToPrint{end}.figureNameEng,'checked','on','Callback',{@nb_graph_package.changeGraphEng,graphsToPrint{end},f,gui},'interruptible','off');

        else

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
    end
        
    % Graph the figures and save them to PDF
    %--------------------------------------------------------------
    inputs = {'-append','-nocrop'};
    if ~obj.flip
        inputs = [inputs,'-noflip'];
    end
    if obj.a4Portrait
        inputs = [inputs,'-a4Portrait'];
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

    counter = 1;
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
                set(graphObj,figTitleProperty,figureTitle);
                try graphObj.plotter.displayValue = displayValue; end %#ok<TRYNC>
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
                    try graphObj.plotter.displayValue = displayValue; end %#ok<TRYNC>

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

            end

        end

        % Graph the figure
        graphObj.saveName = '';
        if ~displayValue % Not saved to PDF
            if isa(graphObj,'nb_graph_adv')
                for jj = 1:size(graphObj.plotter,2)
                    graphObj.plotter(jj).printing2PDF = true;
                end
            else
                graphObj.printing2PDF = true;
            end
        end
        if ~isempty(saveName)
            try
                graphMethod(graphObj,f,gui);
            catch Err
                nb_error(['Error while plotting the graph ' numStr '; ' graphObj.(figureNameProperty)],Err);
            end
            drawnow();
            nb_saveas(gcf,saveName,'pdf',inputs{:});
        end
        
    end
    
    if isempty(saveName) % Preview
        try
            graphMethod(graphObj,f,gui);
        catch Err
            nb_error(['Error while plotting the graph ' numStr '; ' graphObj.(figureNameProperty)],Err);
        end
    end
    
    % Enable graph menu
    %--------------------------------------------------------------
    if numOfGraphs > 1
        set(graphMenu,'enable','on')
    end

end


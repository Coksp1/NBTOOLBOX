classdef nb_table_data_source < nb_graph_obj
% Syntax:
%     
% obj = nb_table_data_source(data)
% 
% Superclasses:
% 
% handle, nb_graph_obj
%         
% Subclasses:
% nb_table_ts, nb_table_data, nb_table_cs
%
% Description:
%
% A class for displaying data in a table.
%
% Constructor:
%
%   obj = nb_table_data_source(data)
% 
%   Input:
%
%   - data : An object of class nb_dataSource
% 
%   Output:
% 
%   - obj  : An object of class nb_table_data
% 
% See also: 
% nb_table.graph
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Save PDF to A4 portrait format. 0 or 1
        a4Portrait              = 0;
        
        % Set to false to prevent adding advanced components.
        addAdvanced             = true;
        
        % Sets the plotted annotations of the graph.
        % 
        % Must be one or more nb_annotation objects. See the 
        % documentation of the class for more. If you give more objects 
        % they must be collected in a cell.         
        annotation              = []; 
        
        % Set size of each column. As a 1 numCol double.
        columnSizes             = {};
        
        % Set columns span of the table. Must be a cell with the same size
        % as the data of the table. Give 2 to make a element span two
        % columns. Empty cell elements are given default values.
        columnSpan              = {};
        
        % Sets the how the figure is saved to .pdf and other figure 
        % formats. If 1 is given the output file will be cropped. 
        % Default is not to crop (i.e. set to 0).         
        crop                    = 0; 
        
        % Round numbers to the number of decimals. Default is 4. Can
        % either be an integer or a string with the printed format of the
        % numbers in the table. E.g. 4, '%.4f'. See num2str for more.
        decimals                = 4;
        
        % Set this property to multiply the data with a given factor. 
        % Must be a scalar.        
        factor                  = 1; 
        
        % Color of the figure as a 1x3 double. Default is
        % [1 1 1].
        figureColor             = [1 1 1];
        
        % Position of the figure as a 1x4 double. Default is
        % []. I.e. use the MATLAB default. In characters.
        figurePosition          = [];
        
        % Sets the name of figure (only in MATLAB), default is no name.
        figureName              = 'none'; 
        
        % For some reason the graph is sometimes flipped and sometimes not.
        % If the graph is flipped use this property to flip it back.
        flip                    = 0;
        
        % Sets the name of font used. Default is 'arial'.
        fontName                = 'Arial';          
        
        % Sets the parameter that scales all the font sizes of the 
        % graphs. Must be scalar. Default is 1 (do not scale).
        fontScale               = 1;
        
        % Sets the font size of the table, default is 12. Must be a scalar.
        fontSize                = 12;
        
        % Sets the font units of all the fonts of the graph. Either
        % {'points'} | 'normalized' | 'inches' |  'centimeters'. 
        % Default is 'points'.
        % 
        % Caution : If you set the fontUnits property in a method call
        %           to the set method, all the font properties set 
        %           before the fontUnits property will be set in the
        %           old fontUnits, while all the font properties set 
        %           after will be in the new fontUnits.
        % 
        % Caution : 'normalized' font units must be between 0 and 1.
        %           The normalized units are not the same as the MATLAB
        %           normalized units. This normalized units are not
        %           only normalized to the axes size, but also across
        %           resolution of the screen. (But only vertically)
        fontUnits               = 'points'; 
         
        % Set the horizontal alignment of each cell of the table. Must be 
        % a cell with the same size as the data of the table. Empty cell
        % elements are given default values.
        horizontalAlignment     = {};
        
        % Sets the language styles of the graphs. Must be a string with 
        % either 'norsk' or 'english'. 'english' is default. I.e. axis
        % settings differs between norwegian and english graphs.        
        language                = 'english';
        
        % A nb_struct with the local variables of the nb_graph 
        % object. I.e. a field with name 'test' can be reach with
        % the string input %#test.
        localVariables          = [];
        
        % Sets how the given mnemonics (variable and type names) should 
        % map to different languages. Must be cell array on the form:
        % 
        % {'mnemonics1','englishDescription1','norwegianDescription1';
        % 'mnemonics2','englishDescription2','norwegianDescription2'};
        % 
        % Or a .m file name, as a string. The .m file must include
        % (and only include) what follows:
        % 
        % obj.lookUpMatrix = {
        % 'mnemonics1','englishDescription1','norwegianDescription1';
        % 'mnemonics2','englishDescription2','norwegianDescription2'};  
        lookUpMatrix            = {};
        
        % Set it to 1 if no label(s) is/are wanted on the graphs, 
        % otherwise set it to 0. Default is 0. This is of course only have  
        % an effect if the nb_table_data_source object have been given the   
        % xLabel properties. (These are empty by default.)        
        noLabel                 = 0; 
        
        % If the font should be normalized to the figure or axes.
        % Either 'figure' or 'axes'.
        normalized              = 'figure';
        
        % Set it to 1 if you don't want title(s) of the table, 
        % otherwise set it to 0. Default is 0. 
        noTitle                 = 0;       
        
        % Sets the page of the data object to table. Default is 1. 
        page                    = [];
        
        % Set it to 1 if you want store all the created graphs produced 
        % in one pdf file. Must be use in combination with the saveName 
        % property.
        pdfBook                 = 0;                
        
        % Sets the plot aspect ratio. Either [] or '[4,3]'. Default
        % is [].
        %
        % When set to '[4,3]' the aspect ratio of the figure is
        % 4 to 3, or when '[16,9]' the aspect ratio of the figure 
        % is 16 to 9
        plotAspectRatio         = [];
        
        % Sets the position of the axes, must be an 1x4 double array. 
        % [leftMostPoint lowestPoint width height]. Only an option for 
        % the graph() method. Default is [0.1 0.1 0.8 0.8].        
        position                = [0.1 0.1 0.8 0.8];               
        
        % Set row span of the table. Must be a cell with the same size
        % as the data of the table. Give 2 to make a element span two
        % rows. Empty cell elements are given default values.
        rowSpan                 = {};
        
        % Sets the saved file name. If not given, no file(s) is/are 
        % produced. Must be a string. 
        % 
        % Default is to save each graph produced in separate files. Set 
        % the pdfBook property to 1 if you want to save all the produced 
        % graphs in one pdf file. (To save all figures in one file is 
        % only possible for pdf files. I.e. the fileFormat property
        % must be 'pdf'.)         
        saveName                = '';   
        
        % Sets the spacing between the data points displayed in the table. 
        % Must be a scalar. Default is 1.    
        spacing                 = 1;   
        
        % A nb_table object storing the information of the displayed table
        table                   = nb_table;
        
        % Used by the nb_graph_subplot class to locate the nb_graph
        % object in the subplot. Should not be used. Use userData
        % instead.
        tag                     = 1;
        
        % Sets the template of the table. See 
        % nb_table.stylingPatternsTemplate for the supported templates.
        template                = 'nb';
        
        % Sets the title of the plot. Must be a char. Only an option 
        % for the graph(...) method.        
        title                   = '';               
        
        % Sets the figure title text alignment, default is 'center'. You 
        % also have 'left' and 'right'.
        titleAlignment          = 'center'; 
        
        % Sets the font size of the titles which is placed above the 
        % (sub)plot(s). Must be scalar. Deafult is 14.        
        titleFontSize           = 14;               
        
        % Sets the font weight of the titles which is placed above the 
        % (sub)plot(s). Must be a string. Default is 'bold'.
        % 
        % Either 'bold', 'normal', 'demi' or 'light'.        
        titleFontWeight         = 'bold';           
        
        % Sets the interpreter used for the given string given by the 
        % title property.
        % 
        % > 'latex' : For mathematical expression 
        % > 'tex'   : Latex text interpreter,
        % > 'none'  : Do nothing        
        titleInterpreter        = 'none';  
        
        % Sets the placement of the title. {'center'} | 'left' | 'right' |
        % 'leftaxes'.
        titlePlacement          = 'center';
        
        % Sets (add) the text of the x-axis label. Must be a string.      
        xLabel                  = '';               
        
        % Sets the x-axis label text alignment, default is 'center'. You 
        % also have 'left' and 'right'.
        xLabelAlignment         = 'center'; 
        
        % Sets the font size of the x-axis label. Must be scalar. 
        % Default is 12.        
        xLabelFontSize          = 12;               
        
        % Sets the font weight of the x-axis label. Must be string.
        % Either 'bold', 'normal', 'demi' or 'light'.        
        xLabelFontWeight        = 'bold';          
        
        % The interpreter used for the given string given by the xLabel 
        % property.
        % 
        % > 'latex' : For mathematical expression 
        % > 'tex'   : Latex text interpreter,
        % > 'none'  : Do nothing        
        xLabelInterpreter       = 'none'; 
        
        % Sets the placement of the x-axis label. {'center'} | 'left' | 
        % 'right' | 'leftaxes'.
        xLabelPlacement         = 'center';
        
        % User data, can be set to anything you want.
        userData                = '';
        
    end
    
    properties (SetAccess=protected)
        
        % A nb_dataSource object storing the data of the table
        DB                      = nb_ts;
        
    end
    
    properties (Access=public,Hidden=true)
        
        % Set to true to add Figur 1 to the first line of figureTitleNor
        % and Graph 1 to figureTitleEng.
        defaultFigureNumbering  = false;
        
        % The parent as an nb_GUI object. Needed for default 
        % settings
        parent                  = [];
        
        % Set to true during writing to .eps or .pdf to fix error in
        % writing en-dash and em-dash to the file formats.
        printing2PDF            = false;
        
    end
    
    properties(Access=protected)
        
        advanced                    = 0;                % Sets if the nb_table_data_source object is used in an nb_table_adv object or not.
        axesHandle                  = [];               % Handle to the current nb_axes object
        figTitleObjectEng           = [];               % Handle to a nb_figureTitle object added to the graph (English)
        figTitleObjectNor           = [];               % Handle to a nb_figureTitle object added to the graph (Norwegian)
        figureHandle                = [];               % The handle to the all the nb_figure handles
        footerObjectEng             = [];               % Handle to a nb_footer object added to the graph (English)
        footerObjectNor             = [];               % Handle to a nb_footer object added to the graph (Norwegian)
        graphMethod                 = 'graph';
        manuallySetFigureHandle     = 0;                % Indicator if the figureHandle has been set manually
        listeners                   = [];               % A vector of listeners to annotation objects.
        
        % When the properties startGraph, endGraph, stopStrip, xTickStart, 
        % barShadingDate and defaultFans are assign with local variables 
        % the notation obj. will return the interpreted value when returnLocal, 
        % is set to 0, otherwise the local variable syntax is returned.
        returnLocal                 = 0;   
        UIContextMenu               = [];               % Context menu related to the nb_axes object
        
    end
    
    events
        
        % Event triggered when the table is updated
        updatedGraph
        
    end
    
    methods
        
        function obj = nb_table_data_source(data)
           
            obj.DB = data;
            
        end
        
        function setSpecial(obj,varargin)
        % Undocumented function to set properties which are 
        % protected 
            
            if size(varargin,1) && iscell(varargin{1})
                % Makes it possible to give options directly through a cell
                varargin = varargin{1};
            end

            for jj = 1:2:size(varargin,2)

                propertyName  = varargin{jj};
                propertyValue = varargin{jj + 1};

                if ischar(propertyName)

                    switch lower(propertyName)
                        
                        case 'advanced'
                            
                            obj.advanced = propertyValue;
                            
                        case 'defaultfigurenumbering'
                            
                            obj.defaultFigureNumbering = propertyValue;    

                        case 'figurehandle'

                            obj.figureHandle = propertyValue;
                            if isempty(propertyValue)
                                obj.manuallySetFigureHandle = 0;
                            else
                                obj.manuallySetFigureHandle = 1;
                            end
                            
                        case 'figtitleobjecteng'
                            
                            obj.figTitleObjectEng = propertyValue;
                            
                        case 'figtitleobjectnor'
                            
                            obj.figTitleObjectNor = propertyValue;    
                            
                        case 'footerobjecteng'
                            
                            obj.footerObjectEng = propertyValue;  
                            
                        case 'footerobjectnor'
                            
                            obj.footerObjectNor = propertyValue;
                            
                        case 'fontunits'

                            oldFontSize   = obj.fontUnits;
                            obj.fontUnits = propertyValue;
                            setFontSize(obj,oldFontSize);
                             
                        case 'localvariables'
                            
                            % Set local variables without testing
                            obj.localVariables    = propertyValue;
                            if isa(obj.DB,'nb_dataSource')
                                obj.DB.localVariables = propertyValue;
                            end

                        case 'manuallysetendtable'

                            obj.manuallySetEndTable = propertyValue;

                        case 'manuallysetstarttable'

                            obj.manuallySetStartTable = propertyValue;
                            
                        case 'plotaspectratio'
                            
                            obj.plotAspectRatio = propertyValue;
                            
                        case 'returnlocal'
                            
                            obj.returnLocal = propertyValue;
                            
                        case 'uicontextmenu'
                            
                            obj.UIContextMenu = propertyValue;
                            
                        case 'variablestoplot'
                            
                            obj.variablesToPlot = propertyValue;

                    otherwise

                            error([mfilename ':: The class nb_table_data_source has no property ''' propertyName ''' or you have no access to set it.'])
                    end

                end
            end

        end
        
        function clean(obj)
        % Will remove the advanced components, as figure titles and
        % footers
            
            obj.figTitleObjectNor = [];
            obj.figTitleObjectEng = [];
            obj.footerObjectNor   = [];
            obj.footerObjectEng   = [];
            obj.noTitle           = 0;
            
        end
           
    end
    
    methods(Access=public,Hidden=true)
        
        function addDefaultContextMenu(obj)
        % Adds default context menu to the graphs axes 
            
            obj.UIContextMenu = uicontextmenu();
            graphMenu         = uimenu(obj.UIContextMenu,'Label','Table');
            dataMenu          = uimenu(obj.UIContextMenu,'Label','Data');
            propertiesMenu    = uimenu(obj.UIContextMenu,'Label','Properties');
            annotationMenu    = uimenu(obj.UIContextMenu,'Label','Annotation');
            addMenuComponents(obj,graphMenu,dataMenu,propertiesMenu,annotationMenu)
            
        end
        
        function graphUpdate(obj,~,~)
        % Callback function listening to the changedGraph event
        
            graph(obj);
            
            % Notify listeners
            notify(obj,'updatedGraph');
             
        end
        
        function notifyUpdate(obj,~,~)
        % Callback function listening to the changedGraph event
        
            % Notify listeners
            notify(obj,'updatedGraph');
             
        end
        
        function notifyStyleUpdate(obj,~,~)
        % Callback function listening to the changedGraph event
        
            % Store selected template to object.
            obj.template = obj.table.stylingPatterns(1).template;
             
        end
        
        function lookUpGUI(obj,~,~)
        % Set the property look up matrix

            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the table is empty.')
                return
            end
        
            % Make GUI
            gui = nb_lookUpGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);

        end
        
        function spreadsheetGUI(obj,~,~)
        % Create simple spreadsheet of data behind figure    

            if isempty(obj.DB)
                nb_errorWindow('The data of the table is empty and cannot be displayed.')
                return
            elseif iscell(obj.DB)
                nb_errorWindow('The data of the table is a matlab cell array and cannot be displayed.')
                return
            end

            if isa(obj.parent,'nb_GUI')
                gui = nb_spreadsheetAdvGUI(obj.parent,obj.DB,1);
                addlistener(gui,'saveToGraph',@obj.resetDataCallback);
            else
                nb_spreadsheetSimpleGUI(obj.parent,obj.DB);
            end

        end
        
        function updateGUI(obj,~,~)
        % Update data of graph and replot

            if isempty(obj.DB)
                nb_errorWindow('The table is empty and cannot be updated.')
                return
            end

            oldDB = obj.DB;
            if obj.DB.isUpdateable()

                try
                    newDB = oldDB.update('off','on');
                catch Err
                    message = ['The data couldn''t be updated.',char(10),char(10), ...
                               'Either the link to the data source is broken, or you don''t have access to the',char(10),...
                                'relevant databases (To update from a Fame database, you need to have MACM installed).',char(10),...
                                'MATLAB error: '];
                    nb_errorWindow(char(message), Err);
                    return
                end

                h.data = newDB;
                resetDataCallback(obj,h,[])

            else
                nb_errorWindow('The data of the table is not updateable. No link to the data source.')
            end

        end
        
        function resetDataCallback(obj,hObject,~)
        % hObject: A nb_spreadsheetAdvGUI object   
            
            % Check that the graph window is not closed
            f = get(obj,'figureHandle');
            if ~ishandle(f.figureHandle)
                nb_errorWindow('You have closed the table window, so the changes cannot be applied')
                return
            end
            
            newData         = hObject.data;
            [message,err,s] = updatePropsWhenReset(obj,newData);
            if err
                nb_errorWindow(message);
                return
            end
            
            if isempty(message)
                message = 'Are you sure you want to save the updated data to the table?';
            else
                message = char(message,'');
                message = char(message,'Are you sure you want to proceed?'); 
            end
            
            nb_confirmWindow(message,@notUpdateCurrent,{@updateCurrent,obj,s,hObject},'Reset data');
            
            function updateCurrent(hObject,~,obj,s,spreadsheetGUI)

                % Close confirm window
                close(get(hObject,'parent'));
                
                % Here I update the properties given the possible loss of data
                % or observations
                props  = s.properties;
                fields = fieldnames(props);
                for ii = 1:length(fields)
                    obj.(fields{ii}) = props.(fields{ii});
                end
                
                % Check that the spreadsheet is not closed
                if isa(spreadsheetGUI,'nb_spreadsheetGUI')
                    if ~isvalid(spreadsheetGUI)
                        nb_errorWindow('You closed the spreadsheet window, so the changes cannot be applied.')
                        return
                    end
                end
                
                % Reset data
                nData  = spreadsheetGUI.data;
                obj.DB = nData;
               
                % Update graph
                try
                    graphUpdate(obj,[],[])
                    if isa(spreadsheetGUI,'nb_spreadsheetGUI')
                        delete(spreadsheetGUI.figureHandle);
                    end
                catch ErrT
                    nb_errorWindow(['Table could not be updated with your data changes. MATLAB error:: ' ErrT.message])
                end

            end

            function notUpdateCurrent(hObject,~)

                % Close confirm window
                close(get(hObject,'parent'));

            end
            
        end
        
        function editNotes(obj,~,~)
           
            if isempty(obj.DB)
                nb_errorWindow('Cannot edit notes, because the data of the table is empty.')
                return
            end
            
            nb_editNotes(obj);
            
        end
        
        function addAxesTextGUI(obj,hObject,~)
        % Callback function for open up a dialog box for editing axes text
        % components as title and labels.

            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the table is empty.')
                return
            end
        
            type = get(hObject,'tag');
            gui  = nb_axesTextGUI(obj,type);
            addlistener(gui,'changedGraph',@obj.graphUpdate);

        end
        
        function generalPropertiesGUI(obj,~,~)
        % Set properties with the general properties GUI

            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the table is empty.')
                return
            end
        
            % Make GUI
            gui = nb_generalTableGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);

        end
        
        function setPageGUI(obj,~,~)
        % Set properties of the axes in a GUI

            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the table is empty.')
                return
            end
        
            % Make GUI
            gui = nb_setPageGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);

        end
        
        function setObservationsGUI(obj,~,~,type)
        % Set properties of the axes in a GUI

            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the table is empty.')
                return
            end
        
            % Make GUI
            gui = nb_selectTableObservationsGUI(obj,type);
            addlistener(gui,'changedGraph',@obj.graphUpdate);

        end
        
        function reorderGUI(obj,~,~,type)
        % Open up a new window to reorder the variables, types or dates GUI
        
            if isa(obj,'nb_table_cs')               
                if strcmpi(type,'variables')
                    reorderGUIObj = nb_reorderGUI(obj.variablesOfTable,'Reorder variables');
                else
                    reorderGUIObj = nb_reorderGUI(obj.typesOfTable,'Reorder types');
                end  
            elseif isa(obj,'nb_table_ts')
                if strcmpi(type,'variables')
                    reorderGUIObj = nb_reorderGUI(obj.variablesOfTable,'Reorder variables');
                else
                    if isempty(obj.datesOfTable)
                        nb_errorWindow('Cannot reorder dates. Go to Select->Dates and select a sub-sample to be able to re-order.')
                        return
                    end
                    reorderGUIObj = nb_reorderGUI(obj.datesOfTable,'Reorder dates');
                end  
            else % nb_table_data
                if strcmpi(type,'variables')
                    reorderGUIObj = nb_reorderGUI(obj.variablesOfTable,'Reorder variables');
                else
                    if isempty(obj.observationsOfTable)
                        nb_errorWindow('Cannot reorder observations. Go to Select->Observations and select a sub-sample to be able to re-order.')
                        return
                    end
                    reorderGUIObj = nb_reorderGUI(nb_double2cell(obj.observationsOfTable,'%.0f'),'Reorder observations');
                end 
            end    
            addlistener(reorderGUIObj,'reorderingFinished',@obj.reorderCallback);

        end
        
        function reorderCallback(obj,hObject,~)
        % hObject : An object of class nb_reorderGUI
        
            if ~isempty(strfind(hObject.name,'variables'))
                type = 'variables';
            elseif ~isempty(strfind(hObject.name,'dates'))
                type = 'dates';
            elseif ~isempty(strfind(hObject.name,'observations'))
                type = 'observations';
            else
                type = 'types';
            end
        
            reordered = hObject.cstr';
            if isempty(reordered)
                return
            end
            switch lower(type)
                
                case 'variables'
                    obj.variablesOfTable = reordered;
                case 'types'
                    obj.typesOfTable = reordered;
                case 'dates'
                    obj.datesOfTable  = reordered;
                case 'observations'
                    
                    if nb_sizeEqual(reordered,[1,nan])
                        reordered = reordered';
                    end
                    reordered = str2num(char(reordered))'; %#ok<ST2NM>
                    obj.observationsOfTable  = reordered;
            end
            
            % Update the graph and notify listeners
            graphUpdate(obj,[],[]);
        
        end
        
        function addTextBox(obj,~,~)
        % Add text box to current figure

            if isempty(obj.DB)
                nb_errorWindow('Cannot add annotation, because the data of the table is empty.')
                return
            end
        
            % Create an text box object 
            ann = nb_textBox('string',  'text',...
                             'xData',   0.5,...
                             'yData',   0.5,...
                             'units',   'normalized');

            % Assign it to the plotter object
            old = obj.annotation;
            new = [old,{ann}];
            obj.annotation = new;
            obj.graph();
            
            % Notify listeners
            notify(obj,'updatedGraph');

        end
        
        function addCurlyBrace(obj,~,~)
        % Add text box to current figure

            if isempty(obj.DB)
                nb_errorWindow('Cannot add annotation, because the data of the table is empty.')
                return
            end
        
            % Create an text box object 
            ann = nb_curlyBrace('xData',   [0.5,0.6],...
                                'yData',   [0.5,0.6],...
                                'units',   'normalized');

            % Assign it to the plotter object
            old = obj.annotation;
            new = [old,{ann}];
            obj.annotation = new;
            obj.graph();
            
            % Notify listeners
            notify(obj,'updatedGraph');

        end
        
        function addDrawPatch(obj,hObject,~)
        % Add rectangle/circle to the current graph

            if isempty(obj.DB)
                nb_errorWindow('Cannot add annotation, because the table of the graph is empty.')
                return
            end
        
            if strcmpi(get(hObject,'Label'),'circle')
                curvature = [1,1];
            else
                curvature = [0,0];
            end

            % Create an text box object 
            ann = nb_drawPatch(...
                    'position',[0.5,0.5 0.05 0.05],...
                    'units',   'normalized',...
                    'curvature',curvature);

            % Assign it to the plotter object
            old = obj.annotation;
            new = [old,{ann}];
            obj.annotation = new;
            obj.graph();
            
            % Notify listeners
            notify(obj,'updatedGraph');

        end
        
        function addArrow(obj,~,~)
        % Add arrow to the current graph

            if isempty(obj.DB)
                nb_errorWindow('Cannot add annotation, because the data of the table is empty.')
                return
            end
        
            % Create an default arrow object 
            ann = nb_arrow(...
                    'xData',   [0.5,0.6],...
                    'yData',   [0.5,0.6],...
                    'units',   'normalized');

            % Assign it to the plotter object
            old = obj.annotation;
            new = [old,{ann}];
            obj.annotation = new;
            obj.graph();
            
            % Notify listeners
            notify(obj,'updatedGraph');

        end
        
        function addTextArrow(obj,~,~)
        % Add text arrow to the current graph

            if isempty(obj.DB)
                nb_errorWindow('Cannot add annotation, because the data of the table is empty.')
                return
            end
        
            % Create an default arrow object 
            ann = nb_textArrow(...
                    'xData',   [0.5,0.6],...
                    'yData',   [0.5,0.6],...
                    'units',   'normalized',...
                    'string',  'Text');

            % Assign it to the plotter object
            old = obj.annotation;
            new = [old,{ann}];
            obj.annotation = new;
            obj.graph();
            
            % Notify listeners
            notify(obj,'updatedGraph');

        end
        
        function enableUIComponents(obj,~,~) %#ok<INUSD>
            

        end
        
        function add(obj,hObject,~)
            
            type = get(hObject,'tag');
            if isa(obj,'nb_table_cell')
                gui = nb_addToCellGUI(obj.parent,obj.DB,type);
            end
            addlistener(gui,'methodFinished',@obj.resetDataCallback);
            
        end
        
    end
    
    methods (Abstract=true,Hidden=true)
        
        dataAsCell          = getDataAsCell(obj,strip)
        [message,retcode,s] = updatePropsWhenReset(obj,newDataSource)
        addMenuComponents(obj,graphMenu,dataMenu,propertiesMenu,annotationMenu)
        
    end
    
    methods (Access=protected,Hidden=true)
        
        function copyObj = copyElement(obj)
        % Overide the copyElement method of the 
        % matlab.mixin.Copyable class to remove some  
        % handles
        
            % Copy main object
            copyObj = copyElement@matlab.mixin.Copyable(obj);
            
            % Make a deep copy of the plotter object
            copyObj.manuallySetFigureHandle = 0;
            copyObj.figureHandle            = [];
            copyObj.axesHandle              = [];
            copyObj.UIContextMenu           = [];
            copyObj.parent                  = [];
%             if isa(copyObj.localVariables,'nb_struct')
%                 copyObj.localVariables = copy(copyObj.localVariables);
%             end
            
            % Copy all the nb_annotation handles
            if iscell(copyObj.annotation)
            
                for ii = 1:length(copyObj.annotation)
                    copied                 = copyObj.annotation{ii};
                    copyObj.annotation{ii} = copy(copied);
                end
                
            elseif isa(copyObj.annotation,'nb_annotation') 
                copyObj.annotation = copy(copyObj.annotation);
            end
            
            % Copy the figure title and footer handles
            if ~isempty(copyObj.figTitleObjectEng)
                copyObj.figTitleObjectEng = copy(copyObj.figTitleObjectEng);
            end
            if ~isempty(copyObj.footerObjectNor)
                copyObj.footerObjectNor = copy(copyObj.footerObjectNor);
            end
            if ~isempty(copyObj.footerObjectEng)
                copyObj.footerObjectEng = copy(copyObj.footerObjectEng);
            end
            if ~isempty(copyObj.footerObjectNor)
                copyObj.footerObjectNor = copy(copyObj.footerObjectNor);
            end
            copyObj.table = copy(copyObj.table); 
            
        end
        
        function addTitle(obj)
            
            if obj.noTitle ~= 1
                
                if ~isempty(obj.lookUpMatrix)
                    tit = nb_graph.findVariableName(obj,obj.title);
                else
                    tit = obj.title;
                end
                 
                %--------------------------------------------------
                % Plot the title
                %--------------------------------------------------
                if ~isempty(obj.localVariables)
                     tit = nb_localVariables(obj.localVariables,tit);
                end
                tit = nb_localFunction(obj,tit);
                
                t             = nb_title();
                t.parent      = obj.axesHandle;
                t.string      = tit;
                t.alignment   = obj.titleAlignment;
                t.fontName    = obj.fontName;
                t.fontSize    = obj.titleFontSize;
                t.fontUnits   = obj.fontUnits;
                t.fontWeight  = obj.titleFontWeight;
                t.interpreter = obj.titleInterpreter;
                t.normalized  = obj.normalized;
                t.placement   = obj.titlePlacement;
                obj.axesHandle.addTitle(t);
                
            end
            
        end
        
        function addXLabel(obj)
              
            if ~obj.noLabel
                
                xLab = obj.xLabel;
                if ~isempty(xLab)
                    
                    if ~isempty(obj.lookUpMatrix)
                        xLab = nb_graph.findVariableName(obj,xLab);
                    end
                    
                    if ~isempty(obj.localVariables)
                         xLab = nb_localVariables(obj.localVariables,xLab);
                    end
                    xLab = nb_localFunction(obj,xLab);
                    
                    lab             = nb_xlabel();
                    lab.parent      = obj.axesHandle;
                    lab.string      = xLab;
                    lab.alignment   = obj.xLabelAlignment;
                    lab.fontName    = obj.fontName;
                    lab.fontSize    = obj.xLabelFontSize;
                    lab.fontUnits   = obj.fontUnits;
                    lab.fontWeight  = obj.xLabelFontWeight;
                    lab.interpreter = obj.xLabelInterpreter;
                    lab.normalized  = obj.normalized;
                    lab.placement   = obj.xLabelPlacement;
                    obj.axesHandle.addXLabel(lab);
                    
                end
                
            end
            
        end
        
        function addAdvancedComponents(obj,language)
        % Adds figure title and footer if some properties are set.
            
            switch lower(language)
                
                case {'norsk','norwegian'}
                    
                    if ~isempty(obj.figTitleObjectNor)
                        
                        obj.figTitleObjectNor.parent = obj.figureHandle;
                        
                        % Interpret the local variables and functions
                        stringOld = obj.figTitleObjectNor.string;
                        if isstruct(obj.localVariables)
                            stringNew = nb_localVariables(obj.localVariables,stringOld);
                        else
                            stringNew = stringOld;
                        end
                        stringNew = nb_localFunction(obj,stringNew);
                        if obj.defaultFigureNumbering
                            if ischar(stringNew)
                                stringNew = cellstr(stringNew);
                            end
                            if isempty(stringNew)
                                stringNew = {'Tabell 1.1'};
                            else
                                stringNew{1} = ['Tabell 1.1 ' stringNew{1}];
                            end
                            stringNew = char(stringNew);
                        end 
                        obj.figTitleObjectNor.string = stringNew;
                        obj.figTitleObjectNor.update();
                        obj.figTitleObjectNor.string = stringOld;
                        
                    end
                    
                    if ~isempty(obj.footerObjectNor)
                        obj.footerObjectNor.parent = obj.figureHandle;
                        
                        % Interpret the local variables and functions
                        stringOld = obj.footerObjectNor.string;
                        if isstruct(obj.localVariables)
                            stringNew = nb_localVariables(obj.localVariables,stringOld);
                        else
                            stringNew = stringOld;
                        end
                        stringNew                  = nb_localFunction(obj,stringNew);
                        obj.footerObjectNor.string = stringNew;
                        obj.footerObjectNor.update();
                        obj.footerObjectNor.string = stringOld;
                        
                    end
                       
                case {'engelsk','english'}
                    
                    if ~isempty(obj.figTitleObjectEng)
                        
                        obj.figTitleObjectEng.parent = obj.figureHandle;
                        
                        % Interpret the local variables and functions
                        stringOld = obj.figTitleObjectEng.string;
                        if isstruct(obj.localVariables)
                            stringNew = nb_localVariables(obj.localVariables,stringOld);
                        else
                            stringNew = stringOld;
                        end
                        stringNew = nb_localFunction(obj,stringNew);
                        if obj.defaultFigureNumbering
                            if ischar(stringNew)
                                stringNew = cellstr(stringNew);
                            end
                            if isempty(stringNew)
                                stringNew = {'Table 1.1'};
                            else
                                stringNew{1} = ['Table 1.1 ' stringNew{1}];
                            end
                            stringNew = char(stringNew);
                        end 
                        obj.figTitleObjectEng.string = stringNew;
                        obj.figTitleObjectEng.update();
                        obj.figTitleObjectEng.string = stringOld;
                        
                    end
                    
                    if ~isempty(obj.footerObjectEng)
                        
                        obj.footerObjectEng.parent = obj.figureHandle;
                        
                        % Interpret the local variables and functions
                        stringOld = obj.footerObjectEng.string;
                        if isstruct(obj.localVariables)
                            stringNew = nb_localVariables(obj.localVariables,stringOld);
                        else
                            stringNew = stringOld;
                        end
                        stringNew                  = nb_localFunction(obj,stringNew);
                        obj.footerObjectEng.string = stringNew;
                        obj.footerObjectEng.update();
                        obj.footerObjectEng.string = stringOld;
                        
                    end
                      
            end
            
        end
        
        function addAnnotation(obj)
            
            if ~isempty(obj.listeners)
                delete(obj.listeners);
                obj.listeners = [];
            end
            
            if ~isempty(obj.annotation)
                
                if isa(obj.annotation,'nb_annotation')
                   ann = {obj.annotation};  
                else
                   ann = obj.annotation;
                end
                
                ind = true(1,length(ann));
                for jj = 1:length(ann)

                    temp = ann{jj};
                    if isa(temp,'nb_annotation')

                        if isvalid(temp)

                            % Assign parent to plot it
                            if isa(temp,'nb_strategyInterval')

                                % Set the fontUnits to be the same as for the
                                % object itself
                                set(temp,'fontUnits',     obj.fontUnits,...
                                         'fontName',      obj.fontName,...
                                         'normalized',    obj.normalized,...
                                         'grapher',       obj);

                            elseif isa(temp,'nb_barAnnotation')

                                % Set the fontUnits to be the same as for the
                                % object itself
                                set(temp,'fontUnits',     obj.fontUnits,...
                                         'fontName',      obj.fontName,...
                                         'normalized',    obj.normalized,...
                                         'language',      obj.language,...
                                         'parent',        obj.axesHandle);         

                            elseif isa(temp,'nb_textAnnotation')

                                if isa(temp,'nb_textArrow') || isa(temp,'nb_textBox')

                                    % Interpret the string property
                                    oldString = temp.string;
                                    if ~isempty(obj.lookUpMatrix)
                                        newString = nb_graph.findVariableName(obj,oldString);
                                    else
                                        newString = oldString;
                                    end

                                    % Interpret the local variables syntax
                                    if ~isempty(obj.localVariables)
                                        newString = nb_localVariables(obj.localVariables,newString);
                                    end
                                    
                                    % Set the fontUnits to be the same as for the
                                    % object itself
                                    set(temp,'fontUnits',     obj.fontUnits,...
                                             'fontName',      obj.fontName,...
                                             'normalized',    obj.normalized,...
                                             'parent',        obj.axesHandle,...
                                             'string',        newString);
                                         
                                    % Reset to old string
                                    temp.string = oldString;
                                    
                                else
                                    
                                    % Set the fontUnits to be the same as for the
                                    % object itself
                                    set(temp,'fontUnits',     obj.fontUnits,...
                                             'fontName',      obj.fontName,...
                                             'normalized',    obj.normalized,...
                                             'parent',        obj.axesHandle);

                                end     

                            else
                                set(temp,'parent',obj.axesHandle);
                            end
                            
                            if isa(temp,'nb_movableAnnotation')
                                listener      = addlistener(temp,'annotationMoved',@obj.notifyUpdatedGraph);
                                obj.listeners = [obj.listeners,listener];
                            end
                            listener      = addlistener(temp,'annotationEdited',@obj.notifyUpdatedGraph);
                            obj.listeners = [obj.listeners,listener];

                        else
                            ind(jj) = false;
                        end

                    else
                        error([mfilename ':: If the annotation property is set to a cell it should only contain nb_annotation objects. This is not the case for element ' int2str(jj) '.']);
                    end
                    
                    % Remove the invalid annotation objects
                    obj.annotation = ann(ind);

                end
                
            end
            
        end
        
        function setFontSize(obj,oldFontSize,normalizeFactor)
        % Set the font size properties, given the fontUnits property
        % 
        % This method is called each time the fontUnits property is 
        % set   
            
            if nargin < 3
                normalizeFactor = 0.001787310098302;
            end
            
            switch lower(oldFontSize)
                
                case 'points'
            
                    switch lower(obj.fontUnits)

                        case 'points'
                            % Do nothing
                        case 'normalized'
                            obj.fontSize       = obj.fontSize*normalizeFactor;
                            obj.titleFontSize  = obj.titleFontSize*normalizeFactor;
                            obj.xLabelFontSize = obj.xLabelFontSize*normalizeFactor;
                        case 'inches'
                            obj.fontSize       = obj.fontSize/72;
                            obj.titleFontSize  = obj.titleFontSize/72;
                            obj.xLabelFontSize = obj.xLabelFontSize/72;
                        case 'centimeters'
                            obj.fontSize       = obj.fontSize*2.54/72;
                            obj.titleFontSize  = obj.titleFontSize*2.54/72;
                            obj.xLabelFontSize = obj.xLabelFontSize*2.54/72;
                        otherwise
                            error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])
                    end
                    
                case 'normalized'
                    
                    switch lower(obj.fontUnits)
                        case 'points'
                            obj.fontSize       = obj.fontSize/normalizeFactor;
                            obj.titleFontSize  = obj.titleFontSize/normalizeFactor;
                            obj.xLabelFontSize = obj.xLabelFontSize/normalizeFactor;
                        case 'normalized'
                            % Do nothing
                        case 'inches'
                            obj.fontSize       = (obj.fontSize/normalizeFactor)/72;
                            obj.titleFontSize  = (obj.titleFontSize/normalizeFactor)/72;
                            obj.xLabelFontSize = (obj.xLabelFontSize/normalizeFactor)/72;
                        case 'centimeters'
                            obj.fontSize       = (obj.fontSize/normalizeFactor)*2.54/72;
                            obj.titleFontSize  = (obj.titleFontSize/normalizeFactor)*2.54/72;
                            obj.xLabelFontSize = (obj.xLabelFontSize/normalizeFactor)*2.54/72;
                        otherwise
                            error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])
                    end
                    
                case 'inches'
                    
                    switch lower(obj.fontUnits)
                        case 'points'
                            obj.fontSize       = obj.fontSize*72;
                            obj.titleFontSize  = obj.titleFontSize*72;
                            obj.xLabelFontSize = obj.xLabelFontSize*72;
                        case 'normalized'
                            obj.fontSize       = (obj.fontSize*72)*normalizeFactor;
                            obj.titleFontSize  = (obj.titleFontSize*72)*normalizeFactor;
                            obj.xLabelFontSize = (obj.xLabelFontSize*72)*normalizeFactor;
                        case 'inches'
                            % Do nothing
                        case 'centimeters'
                            obj.fontSize       = obj.fontSize*2.54;
                            obj.titleFontSize  = obj.titleFontSize*2.54;
                            obj.xLabelFontSize = obj.xLabelFontSize*2.54;
                        otherwise
                            error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])
                    end
                    
                case 'centimeters' 
                    
                    switch lower(obj.fontUnits)
                        case 'points'
                            obj.fontSize       = (obj.fontSize/2.54)*72; 
                            obj.titleFontSize  = (obj.titleFontSize/2.54)*72; 
                            obj.xLabelFontSize = (obj.xLabelFontSize/2.54)*72; 
                        case 'normalized'
                            obj.fontSize       = ((obj.fontSize/2.54)*72)*normalizeFactor;
                            obj.titleFontSize  = ((obj.titleFontSize/2.54)*72)*normalizeFactor;
                            obj.xLabelFontSize = ((obj.xLabelFontSize/2.54)*72)*normalizeFactor;
                        case 'inches'
                            obj.fontSize       = obj.fontSize/2.54;
                            obj.titleFontSize  = obj.titleFontSize/2.54;
                            obj.xLabelFontSize = obj.xLabelFontSize/2.54;
                        case 'centimeters'
                            % Do nothing
                        otherwise
                            error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])
                    end
                    
            end
            
        end
        
        %{
        -----------------------------------------------------------
        Scale the font size
        -----------------------------------------------------------
        %}
        function oldFontSizes = scaleFontSize(obj)
                     
            % Return the old font sizes
            oldFontSizes    = nan(3,1);
            oldFontSizes(1) = obj.fontSize;
            oldFontSizes(2) = obj.titleFontSize;
            oldFontSizes(3) = obj.xLabelFontSize;
            
            % Adjust the font sizes temporarily
            fac                = obj.fontScale;
            obj.fontSize       = obj.fontSize*fac;
            obj.titleFontSize  = obj.titleFontSize*fac;
            obj.xLabelFontSize = obj.xLabelFontSize*fac;
            
        end
        
        %{
        -----------------------------------------------------------
        Inverse of the adjustFontSize method
        -----------------------------------------------------------
        %}
        function revertFontSize(obj,oldFontSizes)
        
            obj.fontSize       = oldFontSizes(1);
            obj.titleFontSize  = oldFontSizes(2);
            obj.xLabelFontSize = oldFontSizes(3);
            
        end
        
        
    end
    
    methods(Static=true)

        function obj = fromStruct(s)
        % Convert a struct into either a nb_graph_data, nb_graph_ts or 
        % nb_graph_cs object     
            
            if isempty(s)
                obj = [];
                return
            end
        
            if ~isfield(s,'class')
                error([mfilename ':: The struct cannot be converted to a nb_table_ts, nb_table_cs or nb_table_data object. It misses the class field.'])
            end
        
            switch s.class
                
                case 'nb_table_ts'
                    
                    obj = nb_table_ts.unstruct(s);
                    
                case 'nb_table_cs'
                    
                    obj = nb_table_cs.unstruct(s);
                    
                case 'nb_table_data'
                    
                    obj = nb_table_data.unstruct(s);
                    
                case 'nb_table_cell'
                    
                    obj = nb_table_cell.unstruct(s);
                    
                otherwise
                    error([mfilename ':: Unsupported class ' s.class '.'])
            end
        
            
        end
        
    end
    
end
